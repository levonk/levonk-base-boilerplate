---
type: Practice
title: Java Alpine Compatibility — musl libc, Native Libraries, and glibc Workarounds
description: Be aware that Alpine uses musl libc; Java with JNI or native dependencies may fail unless you add glibc compatibility or use a Debian-based runtime.
tags: [java, alpine, musl, glibc, jni, containers, compatibility]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: infrahub-java-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar
    title: infrahub java-sidecar Dockerfile
  - id: infrahub-coredns-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/dns/coredns/docker/Dockerfile.coredns
    title: infrahub CoreDNS Dockerfile
  - id: musl-libc
    resource: https://musl.libc.org/
    title: musl libc
---

# Java Alpine Compatibility

## Failure Mode

A Java application that runs fine on a Debian/Ubuntu JDK fails on Alpine
because Alpine uses `musl libc` instead of `glibc`, and a native library or
Java Native Interface (JNI) call expects glibc symbols.

## Symptoms

- `java.lang.UnsatisfiedLinkError` for a `.so` that loads on Debian but not
  Alpine.
- Character encoding issues because `iconv` behavior differs between musl and
  glibc.
- `apk add build-base` is used as a workaround, but it adds GCC and compilers
  that should not be in a runtime image.
- The CoreDNS Alpine sidecar adds `gnu-libiconv` explicitly to work around
  `iconv` differences.

## Practice

### Prefer glibc for Applications with Native Dependencies

- If the application uses JNI, JNA, netty-tcnative, RocksDB, LMDB, or other
  native libraries, use a `debian:bookworm-slim` or `eclipse-temurin` base
  image (glibc-based).
- Use `eclipse-temurin:17-jre-jammy` or similar for a small, glibc-based JRE.

### When Alpine Is Correct for Java

- Infrastructure sidecars that only need a JRE and a small shell, with no JNI.
- The infrahub `java-sidecar` installs `openjdk17` via `apk` and runs a simple
  `java -version` healthcheck; it does not load native libraries.
- If you must use Alpine with glibc-dependent code, install `gcompat` or a
  `glibc`-compat package and test thoroughly.

### Build-Base Is Not a Fix

- `apk add build-base` installs a C toolchain. It does not make musl glibc.
- Native libraries compiled on Alpine with `build-base` are musl binaries and
  will not run on glibc systems.
