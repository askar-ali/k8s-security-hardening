.PHONY: audit remediate test lint
audit:
	audit/run-all.sh

remediate:
	kubectl apply -f namespaces/ -f rbac/least-privilege.yaml -f policies/kyverno/

test:
	tests/run-policy-tests.sh

lint:
	shellcheck audit/*.sh rbac/*.sh tests/*.sh
