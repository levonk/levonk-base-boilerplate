.PHONY: help check lint test clean

LANG_DIRS := \
	bash \
	powershell \
	csharp \
	java \
	ruby \
	python \
	go \
	rust \
	typescript \
	swift

help:
	@printf "%s\n" "Targets: check lint test clean"
	@printf "%s\n" "Set WORKDIR=/path to reuse materializations across runs"

check:
	@set -eu; \
	for d in $(LANG_DIRS); do \
		printf "==> %s\\n" "$$d"; \
		$(MAKE) -C "$$d" check; \
	done

lint:
	@set -eu; \
	for d in $(LANG_DIRS); do \
		printf "==> %s\\n" "$$d"; \
		$(MAKE) -C "$$d" lint; \
	done

test:
	@set -eu; \
	for d in $(LANG_DIRS); do \
		printf "==> %s\\n" "$$d"; \
		$(MAKE) -C "$$d" test; \
	done

clean:
	@set -eu; \
	for d in $(LANG_DIRS); do \
		$(MAKE) -C "$$d" clean || true; \
	done
