.PHONY: help materialize lint test check clean

TEMPLATE_DIR := $(abspath ./core)
WORKDIR ?= $(shell mktemp -d)
OUTDIR := $(WORKDIR)/ruby-cli

PROJECT_NAME ?= My Tool
PROJECT_SLUG ?= my-tool
PROJECT_CLASS_NAME ?= MyTool
DESCRIPTION ?= A CLI tool

help:
	@printf "%s\n" "Targets: materialize lint test check clean"

materialize:
	@rm -rf "$(OUTDIR)"
	@copier copy --trust --defaults \
		--data "project_name=$(PROJECT_NAME)" \
		--data "project_slug=$(PROJECT_SLUG)" \
		--data "project_class_name=$(PROJECT_CLASS_NAME)" \
		--data "description=$(DESCRIPTION)" \
		"$(TEMPLATE_DIR)" "$(OUTDIR)"

lint: materialize
	@$(MAKE) -C "$(OUTDIR)" lint

test: materialize
	@$(MAKE) -C "$(OUTDIR)" test

check: lint test

clean:
	@rm -rf "$(WORKDIR)"
