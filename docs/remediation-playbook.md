# Remediation playbook

1. Run both audit scripts; save output to `reports/` (git-ignored).
2. Fix order: cluster-admin bindings -> root/privileged pods -> admission control -> network isolation.
3. Roll out policies in `Audit` mode first (`validationFailureAction: Audit`), review
   violations, then switch to `Enforce`.
4. Label namespaces `warn` before `enforce` for Pod Security Admission.
5. Re-run audits; the findings list should be empty.

## Caveats
- Kyverno must be installed separately (not included).
- Scan CronJobs here are starting points; image lists should be generated from live pods.

## Native alternative
`policies/native/` has a ValidatingAdmissionPolicy (Kubernetes 1.30+) for clusters that do not want Kyverno.
