---
modeline: "vim: set ft=markdown:"
title: "Template Catalog: Application Scaffolds"
slug: template-catalog-application-scaffolds
url: {url-to-be-added-after-commit}
synopsis: Catalog of copier templates for bootstrapping application projects across platforms.
author: https://github.com/levonk
date-created: 2025-10-08
date-updated: 2025-10-14
version: 1.0.0
status: "accepted"
aliases: []
tags: [doc/templates, scaffolding]
related-to: ["003-application-organization"]
---

## Copier templates to materialize projects:

.
├── cross-platform
│   └── flutter # Flutter apps
├── internal-docs # documentation explaining these directories and how it's templated
├── job
│   └── typescript
├── mcp
│   └── typescript
├── mobile
│   ├── kotlin-android
│   ├── react-native
│   └── swift-ios
├── package # packages used in apps above
│   └── package-name
│   │   ├── internal-docs
│   │   ├── flutter # only created if a flutter package is being created
│   │   │   ├── core # types and interfaces
│   │   │   ├── adapter-mock
│   │   ├── python  #  only created if a python package is being created
│   │   │   ├── core # types and interfaces
│   │   │   ├── adapter-mock
│   │   ├── typescript #  only created if a typescript package is being created
│   │   │   ├── core # types and interfaces
│   │   │   ├── adapter-mock
│   │   │   ├── adapter-3rdpartyName
└── web
    └── typescript
	├── react
        └── nextjs


Each template should have
	- README.md
	- docs
	- code # obviously
	- tests
	- adapter-mock if appropriate
	- bazel
		- build
		- test
		- run
		- deploy

<!-- vim: set ft=markdown: -->
