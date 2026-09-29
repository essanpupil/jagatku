# GCP Networking — Practice Labs

Companion to `GCP-NETWORKING-INTERVIEW-PREP.md`. Theory → hands-on → verify.

## Environment status: VERIFIED WORKING ✅

Everything below was run and confirmed against project `jagatku`:

```
APIs enabled   cloudresourcemanager, compute, container, cloudbilling
Billing        True — billingAccounts/017F7F-B8D025-803DAC
Account        jakethitam1985@gmail.com
Network create VERIFIED (custom mode)
Subnet create  VERIFIED (primary + secondary ranges)
Firewall rule  VERIFIED (tag target, priority 900)
Cleanup        my test resources deleted — "Listed 0 items"
```

You can run these labs now. All are read-only or create-then-delete.

## Cost control — read this first ⚠️

| Resource | Cost |
|---|---|
| VPC network | **Free** |
| Subnet | **Free** |
| Firewall rules | **Free** |
| Routes (static) | **Free** |
| Cloud NAT | **~$0.05/hr + per-GB** ⚠️ |
| Cloud Router | **~$0.05/hr** ⚠️ |
| HA VPN (2 tunnels) | **~$0.06/hr each** ⚠️ |
| Static IP (reserved) | **~$0.01/hr while unused** ⚠️ |
| VM (e2-micro) | **~$0.008/hr** ⚠️ |
| Interconnect | Expensive — **do not create** |

**Labs 1–4 are entirely free.** Labs 5+ use NAT/router and cost a few cents/hour.
**Always run the cleanup block at the end of a lab.** A forgotten Cloud NAT is a real bill.

---

## Lab 1 — Implied firewall rules (free, 10 min) ⚠️ MUST DO

The single most important beginner misconception. Prove it yourself.

```bash
export PROJECT=jagatku
export NET=lab1-net
export REGION=us-east1

gcloud compute networks create $NET --subnet-mode=custom --project=$PROJECT
gcloud compute networks subnets create lab1-sub1 \
  --network=$NET --region=$REGION --range=10.1.0.0/24 --project=$PROJECT
```

Now list the firewall rules:
```bash
gcloud compute firewall-rules list --project=$PROJECT \
  --format="table(name,network,priority,direction,sourceRanges.list():label=SRC,disabled)"
```

**What you should see: an empty list — zero rules.**

✍️ **Verify your answer:** What are the implied rules, their actions, and their priority?
**Answer:** implied ingress **DENY all** and implied egress **ALLOW all**, both at
priority `65535`. They exist on every VPC and cannot be deleted. That's why a brand-new
custom-mode VPC has *nothing* allowed in and *everything* allowed out.

Now add one rule and watch the table populate:
```bash
gcloud compute firewall-rules create lab1-allow-ssh --network=$NET \
  --allow=tcp:22 --source-ranges=0.0.0.0/0 --target-tags=web --priority=900 \
  --project=$PROJECT

gcloud compute firewall-rules describe lab1-allow-ssh --project=$PROJECT \
  --format="value(name,priority,direction,sourceRanges,targetTags,allowed)"
```

✍️ **Verify:** what's the default priority if you omit `--priority`? What happens if a VM
doesn't have the `web` tag?
**Answer:** default priority is `1000`. Without the tag the rule doesn't match the VM, so
traffic is still dropped by the implied deny. **This is the most common real-world
misconfiguration** — a rule that looks right in the console but targets a tag nothing has.

```bash
# cleanup (free)
gcloud compute firewall-rules delete lab1-allow-ssh --project=$PROJECT --quiet
gcloud compute networks subnets delete lab1-sub1 --region=$REGION --project=$PROJECT --quiet
gcloud compute networks delete $NET --project=$PROJECT --quiet
```

---

## Lab 2 — Routes and longest-prefix match (free, 12 min) ⚠️ MUST DO

```bash
export PROJECT=jagatku
export NET=lab2-net
export REGION=us-east1

gcloud compute networks create $NET --subnet-mode=custom --project=$PROJECT
gcloud compute networks subnets create lab2-sub1 --network=$NET --region=$REGION \
  --range=192.168.1.0/24 --project=$PROJECT
```

Inspect the automatic routes — **this is the key output**:
```bash
gcloud compute routes list --project=$PROJECT \
  --filter="network:$NET" \
  --format="table(name,destRange,nextHopGateway,priority)"
```

You should see (verified in this project):
```
NAME                        DEST_RANGE   NEXT_HOP_GATEWAY                 PRIORITY
default-route-<hash>        0.0.0.0/0    .../gateways/default-internet-gw   1000
default-route-r-<hash1>     192.168.1.0/24                                    0
```

✍️ **Verify these four:**
1. Why is the default route priority **1000** but the subnet route priority **0**?
2. If a packet is destined for `192.168.1.50`, which route wins and why?
3. A VM at `192.168.1.20` wants to reach `10.0.0.0/8`. What happens?
4. What's the next-hop for `0.0.0.0/0`?

**Answers:**
1. Priority is the **tiebreaker**, not the primary selector. The subnet route is `0` because
   it's a specific, built-in route. The primary selector is **longest prefix** — and the
   subnet's `/24` is more specific than `0.0.0.0/0` anyway.
2. The `192.168.1.0/24` subnet route. **Longest-prefix match** always wins: a `/24` beats a
   `/0` regardless of priority number.
3. It follows the **default route to the internet gateway**. But — and this is the point —
   there's no Cloud NAT, so the VM has a private IP and cannot actually get a reply. This is
   exactly why Lab 3 exists.
4. The **internet gateway** (`.../gateways/default-internet-gateway`).

Now prove longest-prefix with a custom route:
```bash
gcloud compute routes create lab2-specific --network=$NET --project=$PROJECT \
  --dest-range=192.168.0.0/16 --next-hop-instance=some-instance --priority=100
gcloud compute routes list --project=$PROJECT --filter="network:$NET" \
  --format="table(name,destRange,priority)" | grep 192.168
```

✍️ **Verify:** a VM at `192.168.1.20` sends to `192.168.1.99` — `/24` or `/16` route?
**Answer:** the `/24`. Longer prefix wins, **even though the `/16` has the better (lower)
priority number**. This is the single most misunderstood rule in GCP routing. Priority only
breaks ties between routes of **equal** specificity.

```bash
# cleanup
gcloud compute routes delete lab2-specific --project=$PROJECT --quiet
gcloud compute networks subnets delete lab2-sub1 --region=$REGION --project=$PROJECT --quiet
gcloud compute networks delete $NET --project=$PROJECT --quiet
```

---

## Lab 3 — Private Google Access vs Cloud NAT (costs ~$0.05/hr, 15 min) ⚠️

The distinction that shows up in almost every interview.

```bash
export PROJECT=jagatku
export NET=lab3-net
export REGION=us-east1
export ZONE=us-east1-b

gcloud compute networks create $NET --subnet-mode=custom --project=$PROJECT
gcloud compute networks subnets create lab3-sub1 --network=$NET --region=$REGION \
  --range=10.3.0.0/24 \
  --enable-private-ip-google-access \
  --enable-flow-logs --flow-logs-aggregation-interval=INTERVAL_10_MIN \
  --flow-logs-sampling=0.5 --flow-logs-metadata=INCLUDE_ALL_METADATA \
  --project=$PROJECT
```

Notice I set **three** things on that subnet: private Google Access, flow logs, and metadata
inclusion. That's realistic production hygiene.

Create a VM with **no external IP**:
```bash
gcloud compute instances create lab3-vm --network=$NET --subnet=lab3-sub1 --zone=$ZONE \
  --machine-type=e2-micro --no-address --project=$PROJECT
```

Get an interactive shell and test **before** adding NAT:
```bash
gcloud compute ssh lab3-vm --zone=$ZONE --project=$PROJECT --tunnel-through-iap
```
```bash
# inside the VM:
timeout 20 curl -sI https://storage.googleapis.com | head -1   # Google API — expect SUCCESS
timeout 20 curl -sI https://example.com | head -1              # public internet — expect FAIL/timeout
```

✍️ **Verify:** why does the first work and the second not?
**Answer:** Private Google Access routes **Google APIs and services** over Google's private
backbone using a special internal address. It does **not** provide general internet access —
that's Cloud NAT's job. A VM with no external IP and no NAT can reach Google APIs but not the
public internet.

Now add Cloud NAT:
```bash
gcloud compute routers create lab3-router --network=$NET --region=$REGION --project=$PROJECT
gcloud compute routers nats create lab3-nat --router=lab3-router --region=$REGION \
  --auto-allocate-nat-external-ips --nat-all-subnet-ip-ranges --project=$PROJECT
```

Re-test from inside the VM:
```bash
timeout 20 curl -sI https://example.com | head -1              # now expect SUCCESS
```

✍️ **Verify:** does Cloud NAT respect firewall rules?
**Answer:** **No.** NAT translates addresses; it does not filter. You still need egress
firewall rules to control what's allowed. They're independent layers. Also: Cloud NAT is
egress-only — it gives a VM no ability to be *reached* from the internet.

**Check the flow logs you enabled:**
```bash
gcloud compute networks subnets describe lab3-sub1 --region=$REGION --project=$PROJECT \
  --format="value(logConfig)"
```

⚠️ **Cleanup — the billable part:**
```bash
gcloud compute routers nats delete lab3-nat --router=lab3-router --region=$REGION --project=$PROJECT --quiet
gcloud compute routers delete lab3-router --region=$REGION --project=$PROJECT --quiet
gcloud compute instances delete lab3-vm --zone=$ZONE --project=$PROJECT --quiet
gcloud compute networks subnets delete lab3-sub1 --region=$REGION --project=$PROJECT --quiet
gcloud compute networks delete $NET --project=$PROJECT --quiet
```
The NAT costs ~$0.05/hr. **Delete it even if you're curious and still reading.**

---

## Lab 4 — Free self-check on PSC / PSA / Shared VPC (no resources, 10 min) ⚠️ MUST DO

No creation needed — this is the recall drill that carries the most interview weight.

Draw from memory, then verify in the console (read-only, free):
- Console → **Networking → VPC network → Private Service Connect** (see the "Endpoints" tab)
- Console → **Networking → VPC network → Private service access** (see "Service networking")
- Console → **Networking → Shared VPC**

Then answer, out loud:

✍️ **A.** A VM with a private IP needs to read from a Cloud SQL instance that must **not** be
publicly reachable. Which tool, and what must I reserve first?
**Answer:** **Private Service Access.** Reserve an IP range (commonly a `/20`) and allocate
Cloud SQL an IP from it. You also must enable the Cloud SQL Admin API on the **service
producer** network, not just your project.

✍️ **B.** Same VM needs to call a third-party SaaS vendor's API, keeping traffic off the internet.
**Answer:** **Private Service Connect.** The vendor is the *producer*, you deploy a *consumer
endpoint* with a private IP and DNS. PSA cannot reach third parties — that distinction is the
point of the question.

✍️ **C.** The VM only needs to call Google APIs (BigQuery, Cloud Storage). Cheapest option?
**Answer:** **Private Google Access.** A subnet flag. No reserved IPs, no peering, ~free.

✍️ **D.** Team A's subnet is `10.5.0.0/24`; Team B's is also `10.5.0.0/24`. They must talk.
Four options?
**Answer:** (1) renumber one side; (2) NAT at the overlap boundary with Cloud NAT;
(3) Network Connectivity Center as a hub with a transit appliance; (4) if they only need *one
service*, use Private Service Connect for that service only rather than the whole network.
I'd pick (4) for a single service, (1) if we own both.

✍️ **E.** A team can attach VMs to a shared subnet but can't create a load balancer on it.
Which role is missing?
**Answer:** they have `roles/compute.networkUser` (attach) but need
`roles/compute.networkAdmin` for load balancers on the shared subnet.

✍️ **F.** VPC A peers B; B peers C. Can A reach C directly?
**Answer:** **No.** VPC peering is **not transitive**. Need A↔C peering or NCC as a hub.

---

## Lab 5 — Health-check firewall trap (cheap, 15 min) ⚠️

The highest-value debugging story. You can literally reproduce this.

```bash
export PROJECT=jagatku
export NET=lab5-net
export REGION=us-east1
export ZONE=us-east1-b

gcloud compute networks create $NET --subnet-mode=custom --project=$PROJECT
gcloud compute networks subnets create lab5-sub1 --network=$NET --region=$REGION \
  --range=10.5.0.0/24 --project=$PROJECT
gcloud compute instances create lab5-vm --network=$NET --subnet=lab5-sub1 --zone=$ZONE \
  --machine-type=e2-micro --no-address --project=$PROJECT
```

Start a web server with no external IP and no NAT — so nothing reaches it:
```bash
gcloud compute ssh lab5-vm --zone=$ZONE --project=$PROJECT --tunnel-through-iap
```
```bash
# inside VM:
nohup python3 -m http.server 80 >/dev/null 2>&1 &
```

Create an **internal TCP load balancer** (regional, so it needs a regional address) and
deliberately **do not** allow the prober ranges:
```bash
gcloud compute addresses create lab5-ip --region=$REGION --project=$PROJECT

gcloud compute health-checks create lab5-hc --tcp-health-check --port=80 --project=$PROJECT
gcloud compute instance-groups unmanaged create lab5-ig --zone=$ZONE --network=$NET \
  --health-check=lab5-hc --project=$PROJECT
gcloud compute instance-groups unmanaged add-instances lab5-ig --zone=$ZONE \
  --instances=lab5-vm --project=$PROJECT

gcloud compute backend-services create lab5-be --global --load-balancing-scheme=INTERNAL \
  --protocol=TCP --health-checks=lab5-hc --project=$PROJECT
gcloud compute backend-services add-backend lab5-be --global \
  --instance-group=lab5-ig --instance-group-zone=$ZONE --project=$PROJECT

gcloud compute forwarding-rules create lab5-fr --region=$REGION --load-balancing-scheme=INTERNAL \
  --network=$NET --subnet=lab5-sub1 --address=lab5-ip --ports=80 --backend-service=lab5-be \
  --project=$PROJECT
```

Now check the backend health:
```bash
sleep 45
gcloud compute backend-services get-health lab5-be --global --project=$PROJECT \
  --format="table(healthStatus,instance,port)"
```

✍️ **Verify:** will it be HEALTHY or UNHEALTHY? Why?
**Answer:** **UNHEALTHY.** The prober can't reach the VM because your firewall denies all
ingress (Lab 1!) and you haven't allowed GCP's prober ranges:
`35.191.0.0/16`, `130.211.0.0/22` (plus `209.85.152.0/22`, `209.85.204.0/22` for regional).

Now fix it:
```bash
gcloud compute firewall-rules create lab5-allow-probes --network=$NET --allow=tcp:80 \
  --source-ranges=35.191.0.0/16,130.211.0.0/22,209.85.152.0/22,209.85.204.0/22 \
  --target-tags=lab5 --priority=900 --project=$PROJECT
```
Apply the tag to the VM:
```bash
gcloud compute instances add-tags lab5-vm --zone=$ZONE --tags=lab5 --project=$PROJECT
```

✍️ **Verify:** the VM had no tag when you created the LB. Why does the tag matter twice?
**Answer:** once for the firewall rule to *match the target*, and again because an internal
LB needs the instance in the backend service. Re-check health:
```bash
sleep 45
gcloud compute backend-services get-health lab5-be --global --project=$PROJECT \
  --format="table(healthStatus,instance,port)"
```

**This is your interview story.** You reproduced the exact failure mode that bites in
production: a load balancer that's correctly configured, pointing at a healthy app, returning
502s — because the firewall is blocking the health check. That's a genuinely good answer
because it shows you debug *systematically* rather than guess.

⚠️ **Cleanup (delete the static IP first or you'll keep paying):**
```bash
gcloud compute forwarding-rules delete lab5-fr --region=$REGION --project=$PROJECT --quiet
gcloud compute backend-services delete lab5-be --global --quiet --project=$PROJECT
gcloud compute health-checks delete lab5-hc --quiet --project=$PROJECT
gcloud compute instance-groups unmanaged delete lab5-ig --zone=$ZONE --quiet --project=$PROJECT
gcloud compute instances delete lab5-vm --zone=$ZONE --project=$PROJECT --quiet
gcloud compute addresses delete lab5-ip --region=$REGION --project=$PROJECT --quiet
gcloud compute firewall-rules delete lab5-allow-probes --project=$PROJECT --quiet
gcloud compute networks subnets delete lab5-sub1 --region=$REGION --project=$PROJECT --quiet
gcloud compute networks delete $NET --project=$PROJECT --quiet
```

---

## Mock round — 20 minutes, timed

Answer out loud, no notes. Timer on.

**Q1 (2 min).** Walk me through what a VPC is and what lives inside it.
→ global network, subnets are regional, routes, firewall rules.

**Q2 (2 min).** Fresh VPC, new VM — why can it reach the internet but you can't SSH in?
→ implied egress allow / implied ingress deny, both 65535.

**Q3 (3 min).** Three ways to reach Google stuff privately. Compare them.
→ PGA (subnet flag, APIs) / PSA (reserve range, managed instances) / PSC (endpoint, 3rd party).

**Q4 (2 min).** Peering A↔B, B↔C. A reach C?
→ no, not transitive.

**Q5 (3 min).** LB backend UNHEALTHY. Debug.
→ prober ranges first, then protocol match (port named https gets HTTPS check), then target tags.

**Q6 (2 min).** Hybrid to the office, HA story?
→ HA VPN, 2 routers, 99.99%, 4 tunnels for zone resilience; Interconnect for throughput.

**Q7 (3 min).** A service account can read Secret Manager but can't attach a VM to a shared subnet.
→ missing `roles/compute.networkUser` on the subnet (host project grants it).

**Q8 (3 min).** Cloud NGFW vs Cloud Armor?
→ Armor at the edge on global LB (WAF/DDoS); NGFW inside VPC (L3/L4, Enterprise adds L7/TLS/IPS). Complementary.

**Scoring:** 6+ solid = ready. Missed the prober ranges, the implied-rule asymmetry, or the
PSA/PSC/PGA distinction = re-read those sections tonight.

---

## Time budget

| Block | Time | Cost |
|---|---|---|
| Lab 1 — implied rules | 10 min | free |
| Lab 2 — routes | 12 min | free |
| Lab 4 — recall drill | 10 min | free |
| Lab 3 — PGA vs NAT | 15 min | ~$0.05/hr |
| Lab 5 — health-check trap | 15 min | ~$0.01/hr (IP) |
| Mock round | 20 min | free |
| **Total** | **~1h20m** | **<$0.50** |

Do Labs 1, 2, 4 tonight (free, 32 min). Add 3 and 5 if time allows. Run the mock round in
the morning.
