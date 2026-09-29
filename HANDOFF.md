# HANDOFF — GCP / Argo CD exposure work

Written at the end of a review + implementation session. Read this before touching `gcp/`.

## TL;DR

Argo CD is now exposed on a **reserved global static IP with a valid Google-managed TLS
certificate**, and the HTTP→HTTPS redirect works. **But HTTPS returns 502** — the GCE
backend is `UNHEALTHY` because the ingress points at service port 443 while the container
only serves plain HTTP. One values line fixes it. See "Immediate next action".

## Current cluster state (verified)

| Item | Value |
|---|---|
| Cluster | `jagat-kube-dev`, `us-east1`, project `jagatku` |
| Static IP | `136.82.81.93` — global, `RESERVED`, `EXTERNAL` |
| Public hostname | `argocd.136.82.81.93.nip.io` |
| Certificate | **Active** — `CN=argocd.136.82.81.93.nip.io`, issuer *Google Trust Services*, valid to 2026-12-28 |
| HTTP → HTTPS | Works (`301` to `:443`) |
| HTTPS | **Broken — `502`** |
| Helm release | `argo-cd`, revision 5, status `deployed` (namespace `argo-cd-system`) |
| Backend health | `argo-cd-argocd-server-443` = **`UNHEALTHY`** |

Ingress annotations now in place and correct:

```
kubernetes.io/ingress.class: gce
kubernetes.io/ingress.global-static-ip-name: jagatku-argo-cd-ingress
networking.gke.io/managed-certificates: argo-cd-argocd-server
networking.gke.io/v1beta1.FrontendConfig: argo-cd-argocd-server
```

Two things that look wrong but are **not**:

- `spec.tls` is empty. GKE ignores it when using the `networking.gke.io/managed-certificates`
  annotation. Do not "fix" this.
- A stale `ingress.gcp.kubernetes.io/pre-shared-cert: mcrt-da317f1b-…` annotation from the
  pre-`gke-iap` era is still present alongside the managed certificate. Harmless but
  confusing; it will disappear if the Ingress is ever recreated.

## Immediate next action

The container runs `argocd-server --port=8080` (plain HTTP, no TLS) but
`configs.params."server.insecure"` is **unset**. The chart's ingress template does:

```gotemplate
{{- $insecure := index .Values.configs.params "server.insecure" | toString -}}
{{- $servicePort := eq $insecure "true" | ternary .Values.server.service.servicePortHttp .Values.server.service.servicePortHttps -}}
```

`""` is not `"true"`, so the ingress backend targets service port **443** (named `https`).
GKE health-checks a port named `https` over **HTTPS**, the pod only speaks HTTP, the check
fails, the backend goes `UNHEALTHY`, and the LB returns 502.

Add to the `values` block in `gcp/jagatku/gke/argo-cd/terragrunt.hcl`:

```yaml
configs:
  params:
    server.insecure: "true"
```

That makes the ingress target port 80 (health-checked over HTTP) and keeps TLS terminating
at the Google load balancer. Then:

```bash
cd gcp/jagatku/gke/argo-cd && terragrunt apply
curl -sk -o /dev/null -w "%{http_code}\n" https://argocd.136.82.81.93.nip.io/   # want 200/302
```

## Do not reintroduce the `$$` bug

A previous failure was caused by `$${dependency…}` in the values heredoc. `$$` is the HCL
escape for a **literal** dollar, so Terragrunt passed the raw string
`${dependency.argo_cd_ip.outputs.address}` into the hostname and the API server rejected it
as an invalid RFC 1123 subdomain. The references in that block **must** be single-`$`.
Escape a dollar only for a literal one that belongs in a Helm value.

## IAP was attempted and is not functional

A `BackendConfig` exists in `argo-cd-system`, but:

- `iapConfig.enabled` is **not** set on the cluster
- secret `argocd-iap-oauth` does **not** exist
- `backendconfig.spec.iap.oauthclientCredentials.secretName` is `""`

The ingress currently uses `gce`, so IAP is not in the path. If it is wanted later, all three
of the above must be fixed **together** — the cluster flag, the OAuth consent screen + client
(Console only, not Terraform), and the secret, then set `ingressClassName: gke-iap` and the
`backendConfig` block in the same change. Setting only the ingress class reproduces the
broken state.

## Files touched this session

`iac-modules` (repo `/Users/essan/Code/iac-modules`, HEAD `1a3b675`):

- `gcp/compute-address/` — **committed**. New module. Supports `scope = REGIONAL | GLOBAL`
  via `count` on `google_compute_address` / `google_compute_global_address`. Note
  `google_compute_global_address` accepts neither `network_tier`, `region`, nor
  `subnetwork` — global addresses are implicitly PREMIUM. Outputs: `address`, `id`, `name`.
- `gcp/service-account/` — untracked, unrelated WIP, not committed.

`jagatku` (HEAD `362d7e1`):

- `gcp/jagatku/gke/argo-cd-ip/` — **new, untracked**. Reserves the static IP. Depends on
  the project unit; reads the region from `cluster.hcl`.
- `gcp/jagatku/gke/argo-cd/terragrunt.hcl` — **modified, uncommitted**. Adds the
  `dependency "argo_cd_ip"`, wires the hostname and the `global-static-ip-name` annotation,
  sets `ingressClassName: gce`, enables the HTTPS redirect, and comments out
  `server.service.type: LoadBalancer` so the Service stays `ClusterIP` and the Ingress is
  the only public path.

Both units still use local `source = "/Users/essan/Code/iac-modules/…"` paths. Untracked and
uncommitted — do not let these land without a tagged module ref.

## Outstanding review findings (GCP stack)

Ordered by severity. None are fixed except where noted above.

1. **CRITICAL — control-plane access from a live network call.**
   `gcp/jagatku/gke/terragrunt.hcl:40`:
   `public_authorized_cidr = "${run_cmd("curl", "api.ipify.org")}/32"`.
   It is evaluated on every Terragrunt command, so `plan` from one network and `apply` from
   another silently rewrites the API-server allowlist, and `destroy` fails if ipify is
   unreachable. It also **corrupts `terragrunt render --format json`** — curl's stdout leaks
   into Terragrunt's, so the output is not parseable (verified). Revert to an explicit
   variable. The module types it as `string`, so change it to `list(string)` first to allow a
   break-glass entry.
2. **CRITICAL — state backend.** `root.hcl:6-10` puts all five units' state in Consul KV on
   a single Vagrant VM over `http://`, with no `access_token` (works only because ACLs are
   disabled), no versioning, no encryption, no HA.
3. **HIGH — `gcp/**` has no CI.** Both Terraform workflows filter `paths: terraform-configs/**`.
   Nothing in GitHub Actions ever plans or validates the GKE stack.
4. **HIGH — module refs broken off the author's machine.** At tag `v0.0.7`, `gcp/vpc/main.tf:24`
   and `gcp/gke/main.tf:8` inside the module repo reference absolute local paths. Needs a
   module-repo fix and a re-tag.
5. **MEDIUM — `secrets/keycloakdb` writes a placeholder.** `secret_data` is not passed, so the
   module default `"ChangeMe"` is published as the active version on every apply, because the
   `google_secret_manager_secret_version` has no `version_alias`. An `ignore_changes` fix
   exists only as an **uncommitted** local edit in `iac-modules`.
6. **MEDIUM — no network policy on the cluster.** Module defaults give
   `addons_config.network_policy_config.disabled = true` and `network_policy_enabled = false`,
   and `enable_cilium_clusterwide_network_policy` is inert because Cilium is not installed
   under `gcp/`. `arc-system` (the Actions Runner Controller) has zero policy coverage.
7. **MEDIUM — `gcp/terragrunt.hcl` is dead code.** Nothing includes it, so the `google`
   provider is never declared. Do **not** "fix" it by making it include `root.hcl` — that
   makes `path_relative_to_include()` evaluate as `gcp` for every unit and collapses all
   five onto one Consul key. `root.hcl:9`'s path scheme is load-bearing.
8. **MEDIUM — `deletion_protection = false`** on the cluster with no state backup.
   `binary_authorization` is set to `PROJECT_SINGLETON_POLICY_ENFORCE` with no policy
   defined anywhere in the stack.
9. **LOW —** no `terragrunt_version` / `terraform_version_constraint`; the committed
   `gcp/jagatku/*/.terraform.lock.hcl` files are inert (real locks live in
   `.terragrunt-cache/`), and `.gitignore` does not cover `*.terraform.lock.hcl`, so they
   can be committed by accident. `helm` module has no `timeout` variable → 300s default with
   `atomic = true`, which can roll back a healthy slow install. `values = <<EOF` is an
   interpolating heredoc. Duplicated unvalidated values: `cluster.hcl:14` hardcodes
   `project = "jagatku"`, `vpc:22` hardcodes `us-east1`.

## Repo-wide findings not yet actioned

From the full-stack review (Terraform, Ansible, K8s manifests, CI):

- Vault **root token** read from `~/.vault_pass` on the self-hosted runner with
  `skip_child_token = true`, and a `cicd-policy` granting `sudo` on `pki*` plus `update` on
  `sys/policies/acl/*`. The repo is **public** and CI runs `pull_request` on that same
  persistent runner, so a file on that disk is reachable by untrusted PR code regardless of
  fork secret protection. This is the single highest-value fix in the whole repo.
- Hardcoded Kubernetes bootstrap token `abcdef.0123456789abcdef` in
  `playbooks/kubernetes/kubeadm-cp/init-defaults.yaml.j2:5`, plus `no_log` commented out on
  the task that mints a live join token
  (`playbooks/kubernetes/kubeadm-join/cluster-join.yaml:6-11`) and a control-plane cert key
  printed in plaintext (`kubeadm-cp/cluster-cp-join.yaml:29-37`).
- `kubernetes-manifest/` is entirely orphaned — no `kustomization.yaml`, no Flux CRs, and
  `flux2/` was deleted in `28b2a45`. If it is ever re-pointed at a cluster, `coredns.yaml`
  has `policyTypes: [Egress]` without the API server allowed, which breaks all
  `*.cluster.local` resolution cluster-wide, and `cillium-hubble.yaml:89-104` allows
  `fromEntities: [world]` with no auth.
- All scanning (checkov, trivy, tflint, ansible-lint) is local-only pre-commit; no workflow
  runs it. `.trivyignore.yaml` references two filenames that do not exist, so its
  suppressions are silently dead.
- `fluxcd-ci.yaml` is entirely commented out.

## Useful commands

```bash
# render the effective config (note: broken JSON until finding #1 is fixed)
cd gcp/jagatku/gke/argo-cd && terragrunt render --format json

# ordering / dependency graph
terragrunt dag graph

# live state
export KUBECONFIG=~/.kube/config
helm list -n argo-cd-system --all
helm history argo-cd -n argo-cd-system
kubectl get ingress,mcrt,frontendconfigs,backendconfigs,svc -n argo-cd-system
kubectl -n argo-cd-system get ingress argo-cd-argocd-server \
  -o jsonpath='{.metadata.annotations.ingress\.kubernetes\.io/backends}'

gcloud compute addresses describe jagatku-argo-cd-ingress --global --project jagatku
```

Tooling notes: terragrunt is v1.1.3 — `render-json` and `--terragrunt-non-interactive` no
longer exist; use `terragrunt render --format json` and run from the unit's directory.
`terragrunt hcl format --check` is the formatter to use on `.hcl` files; there is no
`terragrunt_fmt` pre-commit hook, so nothing enforces it today.
