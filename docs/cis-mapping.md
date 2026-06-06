# Mapping to CIS Kubernetes Benchmark themes

| Control theme | Where it is handled here |
|---------------|--------------------------|
| Minimize cluster-admin use (RBAC 5.1.1) | `audit-rbac.sh`, `rbac/least-privilege.yaml` |
| Minimize wildcard roles (5.1.3) | `audit-rbac.sh` |
| Disable default SA token automount (5.1.5/5.1.6) | `rbac/disable-default-sa-token.sh` |
| Privileged / root containers (5.2.x) | PSA labels, Kyverno policies, `audit-pods.sh` |
| Host namespaces and hostPath (5.2.x) | `disallow-host-access.yaml`, `audit-host-access.sh` |
| Network policies (5.3.2) | `namespaces/default-deny.yaml` |
| Secrets as files not env (5.4.1) | `audit-secrets.sh` |
| Image provenance (5.5.1) | registry policy, `audit-images.sh` |
| Node/control-plane benchmark | `scanning/kube-bench-job.yaml` |

Control numbers are indicative; check them against the benchmark version you use.
