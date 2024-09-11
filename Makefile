## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

HELMIFY ?= $(LOCALBIN)/helmify

.PHONY: helmify
helmify: $(HELMIFY) ## Download helmify locally if necessary.
$(HELMIFY): $(LOCALBIN)
	test -s $(LOCALBIN)/helmify || GOBIN=$(LOCALBIN) go install github.com/arttor/helmify/cmd/helmify@latest

.PHONY: helm
helm: manifests kustomize helmify
	$(KUBECTL) create namespace llmaz-system --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(KUSTOMIZE) build config/default | $(HELMIFY) -crd-dir

.PHONY: helm-install
helm-install: helm
	helm upgrade --install llmaz ./chart --namespace llmaz-system -f ./chart/values.global.yaml
