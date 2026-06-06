# k8s-security-hardening

A repeatable Kubernetes security audit and remediation kit: find the common
high-severity problems, then fix them with declarative manifests.

> Generic lab recreation of the audit approach I use on production clusters
> (since 10/2025). No client data. Placeholder names only.

## What it covers

| Finding | Detection | Fix |
|---------|-----------|-----|
| Over-privileged service accounts / cluster-admin bindings | `audit/audit-rbac.sh` | `rbac/` least-privilege Roles |
| Containers running as root / privileged | `audit/audit-pods.sh` | Pod Security Admission labels + Kyverno policies |
| No admission control | audit checks namespace labels | `namespaces/`, `policies/kyverno/` |
| No default network isolation | audit checks NetworkPolicies | default-deny `NetworkPolicy` |
| Vulnerable images / malware | Trivy + ClamAV | `scanning/` CronJobs |

## Usage

```bash
./audit/audit-rbac.sh     # read-only
./audit/audit-pods.sh     # read-only
kubectl apply -f namespaces/ -f rbac/ -f policies/kyverno/   # remediate
kubectl apply -f scanning/                                    # continuous scans
```
`make audit` runs all audits into `reports/`. `make test` checks policies with the Kyverno CLI.

Audit scripts are read-only and need only `kubectl get` access.
