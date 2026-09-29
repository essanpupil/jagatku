# GCP Networking — Beginner Interview Prep (one night)

Target: Senior DevOps Engineer role at a GCP-focused company. Focus: **GCP networking**.
Built from the ground up — assumes no prior GCP. Grounded on the *Professional Cloud Network
Engineer* exam guide, which is the closest published blueprint for this kind of interview.

**How to use this.** Read Part 1–3 tonight in order (~3 hrs). They build on each other, so
don't skip ahead. Part 6 is a cheat sheet; Part 7 is what to say out loud. Part 8 is what to
admit you don't know.

**A note on framing.** You are interviewing for a *Senior* role, so don't deliver beginner
answers. The content below is beginner-level; the *delivery* should be confident. Say "my
understanding is X, and I'd validate it by Y" rather than guessing — that reads as senior
regardless of depth.

---

## Part 1 — The basics (30 min) ⚠️

Before anything else, you must be fluent on the vocabulary. Most early interview questions
are here.

### Regions and zones
- **Region** = a geographic location (`us-east1`). **Zone** = a datacenter within a region
  (`us-east1-b`). Three+ zones per region typically.
- Zones are isolated failure domains. Deploy across ≥2 zones for HA.
- **"Global" is a real GCP concept that confuses people.** A VPC network, its routes, and its
  firewall rules are **global** resources — not tied to a region. **Subnets are regional.**
  One VPC spans all regions, so you don't peer between your own regions.
- Regions are chosen for **latency to users** and **data residency** obligations, not just capacity.

### IP addresses
- **Private IP** — internal only. Two resources with private IPs in the same VPC can talk
  directly, subject to firewall rules.
- **External (public) IP** — reachable from the internet. Ephemeral (lost on stop) or
  **static** (reserved, survives stop/start; billed per hour).
- Private IPs come from a **subnet's IP range**.

### The resource hierarchy (matters for governance questions)
```
Organization
  └── Folder
        └── Project
              └── Resources
```
- Policies (org policies, firewall policies, budgets) cascade **downward**.
- You can attach a VPC to a **folder or org**, not just a project — this is how you share a
  network across many projects. (Covered in Part 4.)

### IAM vs firewall — the distinction interviewers check
- **IAM** = "who may *do* things" (create a VM, read a bucket). Permissions on resources.
- **Firewall** = "what traffic may *flow*". Applies after the packet exists.
- IAM never blocks a running connection. A firewall rule never grants a permission.
- If asked "how do I stop a developer spinning up VMs in prod" → that's **IAM**, not firewall.

### First mental model
A **VPC** is a global private network. Inside it:
- **Subnets** (regional) hold IP ranges.
- **Routes** tell traffic where to go.
- **Firewall rules** decide what's allowed.
That's the whole system. Everything else is a variation.

---

## Part 2 — VPC, subnets, routing, firewall (50 min) ⚠️

### Subnets
- A subnet is **regional** and **spans all zones** in that region. (Different from AWS, where
  a subnet is zonal — expect to be asked about this difference.)
- A subnet has a **primary IPv4 range** (used by VMs/NICs) and optional **secondary ranges**
  (used by GKE pods and services).
- Subnet **primary range can be expanded** without downtime. **Secondary ranges cannot be
  resized** the same way — plan them carefully. (GKE pod ranges are secondary ranges.)

### Routes ⚠️
- Routes are essentially a **destination-prefix → next-hop** lookup table, plus a priority.
- Built-in routes: default route (`0.0.0.0/0` → internet gateway) and one per subnet
  (each subnet's local range is automatically reachable).
- **Route selection order:**
  1. **Most specific prefix wins** (longest prefix match). This is the dominant rule.
  2. Tie → **static** routes beat dynamic.
  3. Tie → lower priority number wins.
- You can create static routes (manual) and dynamic routes (learned via BGP from a Cloud Router).

### Firewall rules ⚠️ — the part beginners always get wrong
- **Implied rules, always present, cannot be deleted:**
  - **Ingress: DENY all inbound**, priority `65535`.
  - **Egress: ALLOW all outbound**, priority `65535`.
  - (In the default VPC, there are also `default-allow-ssh` and `default-allow-internal` at
    priority `65534`. In a custom VPC these don't exist — safer default.)
- **This asymmetry is the #1 beginner trap:** new VPC = nothing comes in, everything goes out.
  A VM can `apt update` but nobody can SSH to it until you add a rule. Say this out loud.
- A firewall rule needs: direction, source/destination, action (allow/deny), priority, target,
  protocol/ports.
- **Lower priority number = evaluated first.** Range `0`–`65535`, default `1000`.
- Rules are **stateful** — allowed inbound means the reply traffic is automatically allowed.
- You can write **deny** rules. A deny actually drops the flow (it is not merely "no match").
- **Targets**: all instances, by **network tag**, or by **service account**.
- **Network tags are user-controlled** — someone with VM-write can change their own VM's tag
  and walk through a tag-based rule. **Secure tags** add IAM on the tag itself. Prefer secure
  tags or service accounts for anything security-sensitive.

### The health-check firewall gotcha ⚠️
If you put a load balancer in front of your VMs and the backend shows **UNHEALTHY**, the
most common cause is that **GCP's prober IPs are blocked by your firewall rules.** You must
allow these ranges:
```
35.191.0.0/16
130.211.0.0/22
(also 209.85.152.0/22 and 209.85.204.0/22 for regional load balancers)
```
Know these numbers. Knowing *why* (the LB probes from Google infra, which your firewall also
sees as just another source) is what earns the follow-up question.

---

## Part 3 — Connectivity (60 min) ⚠️

### Outbound internet: Cloud NAT
- VMs with no external IP need **Cloud NAT** to reach the internet. It sits on a
  **Cloud Router** and translates private → public for the whole subnet.
- Egress-only, managed, no per-VM management.
- **Cloud NAT is not firewall** — NAT moves traffic; firewall rules still control what's allowed.

### Private Google Access
- A **subnet-level flag** that lets VMs *without* external IPs reach **Google APIs and
  services** (Cloud Storage, BigQuery, Pub/Sub) over Google's private backbone.
- No IP reserved, no peering, no endpoint. Almost free.
- It does **not** let you reach the general internet — that's Cloud NAT.
- It does **not** give private connectivity to a managed *instance* (that's Part 4).

### Private Service Access (PSA)
- For giving a **Google-managed service** (Cloud SQL, Memorystore, AlloyDB) a **private IP**
  inside your VPC.
- You **reserve an IP range** (commonly a `/20`) and allocate the service an IP from it.
- It works by creating a **VPC peering** to a Google-managed "service producer" network.
- **Gotcha:** you must enable the service's API on the **producer** network, not just your project.

### Private Service Connect (PSC)
- Creates a **private endpoint** (with its own internal IP and DNS) in your VPC that connects
  to a *producer*.
- A **producer** is any service — including **third-party SaaS** and services in another
  organization.
- Use when: you need private access to a specific service, especially a third-party one.

### The distinction, drilled ⚠️
This is the single most-asked question. Memorise this table.

| | Private Google Access | Private Service Access | Private Service Connect |
|---|---|---|---|
| What it reaches | Google APIs/services | Google-managed **instances** | Producers, incl. **3rd party** |
| Scope | Subnet | VPC (all subnets) | Per endpoint |
| Reserves IPs? | No | Yes (e.g. `/20`) | Yes (1 per endpoint) |
| Peering? | No | Yes | Optional |
| Reaches public internet? | No | No | No |
| Cost | ~free | Peering | Endpoint + data |

**Say it as:** *"Three different tools. Private Google Access is a subnet flag for reaching
Google APIs — cheap and simple. Private Service Access reserves a range and peers to the
service producer so a managed instance like Cloud SQL gets a private IP. Private Service
Connect creates an endpoint and is the one that reaches third-party services."*

### Cloud DNS
- **Managed zone** = a DNS namespace. **Public** (on the internet) or **private** (VPC-only).
- **Forwarding zone** — delegate a subdomain to an on-prem resolver (e.g. `corp.example.com`
  → internal AD DNS).
- **Peering zone** — a private zone resolving to another VPC's private DNS.
- **Private zone + PSC** = fully private resolution for managed services.
- Remember **reverse lookup** zones (`.in-addr.arpa`) in IPAM design.

### Load balancing (the map) ⚠️
Two big families. Know the split, then the members.

**L4 (network, layer 4)** — TCP/UDP, no HTTP awareness:
- **External passthrough NLB** — the backend keeps its IP; client→backend is direct.
- **Internal passthrough NLB** — internal, backend keeps IP.
- **Internal TCP/UDP LB (proxy)** — internal, backend is hidden behind an internal IP.

**L7 (application, layer 7)** — understands HTTP/HTTPS:
- **Global external HTTP(S) LB** — the classic GCLB; needs a **global static IP**, global anycast
  IPs, works across regions, can attach **Cloud Armor**. (This is what GKE Ingress uses.)
- **Regional external Application LB** — regional, single region, cheaper.
- **Internal Application LB** — internal, layer 7, regional.
- **Serverless NEGs** — for Cloud Run / serverless backends.

**Interviewer gold:** *global vs regional* is a common fork. **Global = anycast IPs, cross-region,
Cloud Armor, GKE multi-cluster. Regional = single region, cheaper, simpler.** And for GKE
Ingress the default GCE ingress is a **global external ALB** (hence `global-static-ip-name`).

### Hybrid / on-prem connectivity
- **Classic VPN** — one tunnel over public internet, 99.0% SLA. Dev/test.
- **HA VPN** — redundant tunnels via **two Cloud Routers**, 99.99% SLA. For production branches.
  - For true zone-resilience, use **four** tunnels (one per zone) — two can share a zonal
    failure domain.
- **Cloud Interconnect** — private physical link to a Google colocation facility.
  - **Dedicated** (your own port, 10/100 Gbps), **Partner** (via a provider, easier to start),
  - **Cross-Cloud Interconnect** — reach AWS/Azure over the public internet.
- **Cloud Router** + **BGP** is required for all dynamic (learned) routing. ASNs, MD5 auth.
- **Dynamic vs static routing:** dynamic = BGP-learned, flexible, needs a router; static =
  manual, no router, doesn't adapt.
- **Network Connectivity Center (NCC)** — hub-and-spoke across many VPCs and on-prem, even
  across regions/orgs. Use instead of peering sprawl.
- ⚠️ **VPC peering is NOT transitive.** A↔B and B↔C does **not** give A↔C. This is a
  classic trap.

---

## Part 4 — Shared VPC, multi-VPC, GKE networking (40 min)

### Shared VPC
- A **host project** owns the network and subnets; **service projects** attach their VMs to
  those shared subnets. Works at folder/org level.
- Central governance, no peering for internal traffic, per-project billing/quota.
- **IAM roles (memorise):**
  - `roles/compute.networkUser` — attach instances to a shared subnet.
  - `roles/compute.networkAdmin` — create/manage load balancers on a shared subnet.
  - `roles/compute.xpnAdmin` — administer the Shared VPC setup.
- Subnet **deletion is restricted** in shared VPC to prevent accidental blast radius.

### VPC peering
- Private connectivity between two VPCs (same or different orgs), no bandwidth bottleneck.
- **Not transitive** (see above). ~20 peerings per network (soft limit).
- Use **custom-route import/export** when on-prem prefixes must flow through.

### Cloud NGFW vs Cloud Armor — don't conflate them ⚠️
- **VPC firewall rules / Cloud NGFW** — inside the VPC, L3/L4, and (Enterprise) L7 + IPS.
  Tiers: Essentials → Standard → Enterprise (Enterprise adds TLS interception + IPS).
- **Cloud Armor** — at the **edge**, on a global external load balancer: WAF, DDoS, rate limiting.
- They are **complementary, not competitors**. Armor at the edge, NGFW inside.

### GKE networking
- **VPC-native (alias IP)** — pods get IPs from a subnet **secondary range**; services from
  another secondary range. This is the modern default. (Routes-based is legacy.)
- **IP planning:** GKE carves a `/24` per node for pods (256 IPs → ~110 pods/node). A `/14`
  pod range ≈ 1,024 nodes. Nodes typically `/20`, services `/20`.
- **Service range (GKE 1.29+ standard / 1.27+ Autopilot):** GKE can supply a managed service
  range (`34.118.224.0/20`) so you only provide the pod range.
- **Control plane access:** public endpoint can be locked to authorised CIDR
  (`master_authorized_networks_config`), or use a private control-plane endpoint.
- **MTU:** VPC default is **1460**. Dataplane V2 raises node MTU to **1500**. A mismatch
  (container advertises 1500, path allows 1460) **silently drops large packets** — symptom is
  "small pages fine, large pages hang." Great troubleshooting answer.
- **GKE internal DNS:** nodes use VPC DNS at `169.254.169.254`; CoreDNS runs as a pod and
  itself must be able to reach the cluster DNS. If in-cluster DNS breaks, check egress to
  **UDP *and* TCP 53** (UDP-only is a classic intermittent-failure bug).

---

## Part 5 — Observability & troubleshooting (20 min)

- **VPC Flow Logs** — per-connection records (allowed/denied, bytes). Enable for audit and
  for "why is X not reaching Y" forensics.
- **Firewall Rules Logging** — which rule matched/dropped a connection.
- **Network Intelligence Center** — topology, reachability analysis, bottleneck detection.
  (Great product to name in a troubleshooting answer.)
- **Connectivity Tests** — built-in reachability checker between source/dest.
- **Cloud NAT logging**, **load balancer request/logging** (e.g. LB request logs on backend).

### The troubleshooting answer template ⚠️
Structure matters as much as content. Interviewers listen for *method*, not just the fix:
1. **Reproduce** — is it DNS, or connectivity? From where? (`dig` vs `curl -v`.)
2. **Is it DNS?** Wrong zone? private zone not attached to the right subnet? UDP+TCP 53?
3. **Is it routing?** Longest-prefix route pointing somewhere unintended? Subnet range overlap?
4. **Is it firewall?** Priority order, implied rules, tag mismatch, or **prober ranges blocked
   (if behind an LB)**.
5. **Look at evidence** — Flow Logs / Firewall logging show the allow/deny decision directly.
6. **Check the health of the thing itself** — serial console output for a VM, `kubectl logs`.

---

## Part 6 — Cheat sheet (memorise) ⚠️

```
VPC / routes / firewall rules   GLOBAL resources
Subnet                          REGIONAL, spans all zones in the region
Implied ingress rule            DENY all,      priority 65535
Implied egress rule             ALLOW all,     priority 65535
Firewall rule priority          0–65535, default 1000, lower = first
Health-check prober ranges      35.191.0.0/16, 130.211.0.0/22
                                (+209.85.152.0/22, 209.85.204.0/22 regional)
VPC default MTU                 1460 (1500 on Dataplane V2)
GKE pod range                   /24 per node (~110 pods); /14 ≈ 1024 nodes
GKE service range               /20 ; managed 34.118.224.0/20 on 1.29+
GKE internal DNS                169.254.169.254
GKE API range                   34.121.0.0/11
HA VPN SLA                      99.99%, min 2 tunnels, 4 for zone resilience
Classic VPN SLA                 99.0%, 1 tunnel
PGA                             subnet flag, Google APIs only, ~free
PSA                             reserve /20 + peer to service producer (managed instances)
PSC                             endpoint IP, reaches 3rd-party / cross-org
Peering                         NOT transitive
Shared VPC roles                networkUser (attach) / networkAdmin (LB) / xpnAdmin (admin)
Cloud NGFW                      inside VPC (Essentials/Standard/Enterprise)
Cloud Armor                     edge, on global LB (WAF/DDoS/rate-limit)
Route tie-break                 specificity > static > dynamic > priority number
```

---

## Part 7 — Likely questions + model answers (rehearse aloud)

> **Q1. Walk me through what a VPC is.**
> A VPC is a global private network spanning all of GCP's regions. Inside it, subnets are
> regional and hold IP ranges; routes decide where traffic goes; firewall rules decide what's
> allowed. Resources with private IPs in the same VPC communicate directly, subject to firewall.

> **Q2. I created a VPC and a VM. Why can't I SSH in, but it can reach the internet?**
> Because of the implied firewall rules. Every VPC has an implied *deny all ingress* and
> *allow all egress* rule, both at the lowest priority (65535). So outbound works with no
> configuration, but nothing is allowed in until I add an ingress rule — e.g. allow TCP 22
> from my IP. In a custom VPC those defaults don't exist; only the implied ones do.

> **Q3. Client VMs have no external IP. How do they reach Google APIs?**
> Private Google Access — a flag I enable on the subnet. It routes Google API traffic over
> Google's private backbone without an external IP or NAT. No IP range is reserved. If I later
> need a *managed instance* like Cloud SQL on a private IP, that's Private Service Access
> instead, which does require reserving a range and a peering to the service producer.

> **Q4. How do you keep third-party SaaS traffic off the internet?**
> Private Service Connect. The third party becomes a producer, I deploy a consumer endpoint in
> my VPC, and it gets an internal IP and private DNS — traffic stays on Google's backbone.
> PSC is the right tool because Private Service Access can't reach third parties.

> **Q5. Team A's VPC must reach Team B's. Their subnets overlap. What do you do?**
> Peering with import/export doesn't help an overlap. Options: renumber one side; NAT at the
> boundary with Cloud NAT; use Network Connectivity Center with a transit appliance; or — if
> they only need one service — use Private Service Connect to expose just that, not the whole
> network. I'd pick the last one if it's a single service, otherwise renumber.

> **Q6. My load balancer backend is UNHEALTHY. What's the first thing you check?**
> Firewall rules blocking the health check. GCP's load balancers probe from
> 35.191.0.0/16 and 130.211.0.0/22 (plus the 209.85.x ranges for regional), and those look
> like just another source to my firewall, so I need to allow them — or enable "allow health
> checks" on the LB. Next I'd check the backend protocol matches: a port named `https` gets an
> HTTPS health check, so if the app only speaks plain HTTP it fails even though curl works.

> **Q7. VPC A peers with B, B peers with C. Can A reach C?**
> No — VPC peering is not transitive. A→B and B→C does not give A→C. I'd either peer A
> directly with C, or use Network Connectivity Center as a hub.

> **Q8. How does the hybrid connection to the office work, and what's the HA story?**
> HA VPN: redundant tunnels through two Cloud Routers with BGP, 99.99% SLA. For full
> zone-resilience I'd run four tunnels — one per zone — so a zonal outage doesn't take out
> both. For higher throughput or lower latency to the office, Interconnect (physical link),
> which pairs with the same Cloud Router/BGP model.

> **Q9. What's the difference between Cloud NGFW and Cloud Armor?**
> They're complementary. Cloud Armor sits at the edge on a global load balancer — WAF, DDoS,
> rate limiting for internet traffic. Cloud NGFW is inside the VPC — it enforces L3/L4 and, at
> the Enterprise tier, L7 inspection with TLS interception and IPS on traffic within the VPC.
> Armor protects the perimeter; NGFW protects east-west and workload traffic.

> **Q10. A VM can't SSH in after a network change. How do you debug?**
> Methodically: confirm DNS vs connectivity first (`dig` then `curl -v`). If it's routing,
> check for a more-specific static route hijacking traffic. If it's firewall, check priority
> order and that my target tag still matches the VM's tags — and whether a network-tag change
> broke a tag-based rule. Then look at the evidence: VPC Flow Logs and firewall rule logging
> show the actual allow/deny decision. As a last resort, serial-port console output to see if
> the instance is even up.

> **Q11. Service account can read Secret Manager but can't attach a VM to a shared subnet.**
> Missing `roles/compute.networkUser` on the subnet. Shared VPC has two parties: the host
> project owns the subnet and must grant the service project's principals subnet-level access.
> `networkUser` allows attaching instances; `networkAdmin` is needed if they also have to
> create load balancers on that subnet.

> **Q12. Why is our GKE cluster slow on large requests but fine on small ones?**
> MTU mismatch. VPC internal MTU is 1460 by default; Dataplane V2 raises node MTU to 1500. If
> the container advertises 1500 but the path only supports 1460, large packets get silently
> dropped — small ones fit, big ones hang. I'd check whether anything on the path (a legacy
   network, an on-prem hop) still only supports 1460 and align the MTU.

---

## Part 8 — Gaps to name honestly

Volunteering these reads as senior; getting caught on them doesn't. Frame as: *"I know the
design and I've built it in a lab/small setup; multi-region and large-scale hybrid are where
I'd want to ramp up under a team."*

- **Multi-region / global load balancing across regions** — designed it, run one region.
- **Large-scale hybrid** — VPN/Interconnect basics, not a 20-VPC NCC mesh.
- **IPv6 / dual-stack** — can plan ranges; haven't run in production.
- **Cloud NGFW Enterprise tuning** (TLS interception, IPS) — know the tiers, not tuned under attack.
- **Deep GCP-native Big Data networking** (e.g. private patterns for Dataproc/Dataflow at scale).

---

## Tomorrow morning — 30 minutes

1. Redraw the **Part 3 private-connectivity table** and the **load-balancing family map** from
   memory.
2. Say **Q1, Q2, Q3, Q6, Q7** out loud without notes.
3. Memorise the **Part 6 cheat sheet** — the prober ranges and implied-rule priorities are free marks.
4. Prepare **one short story** about a real problem you debugged (even from your own lab) —
   what broke, how you narrowed it, what fixed it. It proves you debug rather than guess.
5. Re-read **Part 8** so you can name your gaps calmly.
