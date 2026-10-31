.PHONY: tools cluster argocd rollouts access clean

tools:
	./scripts/install-tools.sh

cluster:
	./scripts/create-cluster.sh
	kubectl get nodes
	kubectl get pods -A

argocd:
	./scripts/install-argocd.sh
	kubectl get pods -n argocd

rollouts:
	./scripts/install-rollouts.sh
	kubectl get pods -n argo-rollouts

access:
	./scripts/access-argocd.sh

clean:
	./scripts/cleanup.sh
