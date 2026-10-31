.PHONY: tools cluster argocd rollouts access clean

tools:
	./scripts/install-tools.sh

cluster:
	./scripts/create-cluster.sh

argocd:
	./scripts/install-argocd.sh

rollouts:
	./scripts/install-rollouts.sh

access:
	./scripts/access-argocd.sh

clean:
	./scripts/cleanup.sh
