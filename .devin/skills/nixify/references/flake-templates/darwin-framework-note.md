# Darwin Framework Note

Many language ecosystems need macOS system frameworks when building on Darwin.
The specific frameworks and when they are required vary by language and by
whether the project uses system TLS/keychain or bundles its own.

## Rust

Rust crates that link `native-tls` (for example `reqwest` with its default
`native-tls` feature, `hyper-tls`, or any crate that calls into macOS security
APIs) require the `Security` and `SystemConfiguration` frameworks on Darwin.
`libiconv` is also commonly needed for general Darwin builds.

## .NET

The .NET runtime uses the `Security` and `CoreFoundation` frameworks for TLS
and certificate validation on Darwin. `buildDotnetModule` on Darwin needs both
frameworks in `buildInputs`.

## Swift

Swift on Darwin links against system frameworks natively — Swift was designed
for Apple platforms, so framework linking is more extensive than other
languages. `Foundation`, `Security`, and `CoreFoundation` are commonly needed.

## Go

Pure Go TLS (`crypto/tls`) does **not** need Darwin frameworks — Go bundles its
own TLS implementation. cgo projects that use system TLS or keychain access
**do** need `Security`. For example, `go-sqlite3` (cgo) may need `Security` for
keychain access.

## Python

CPython extensions that use `ctypes` to call into the Security framework need
it at build/runtime. The `keyring` library needs `Security` on Darwin. The
`cryptography` package builds against OpenSSL but may need `Security` for
access to the system trust store.

## Node.js

Node bundles its own OpenSSL, so pure JavaScript code does not need Darwin
frameworks. N-API addons using `node-addon-api` that call into system TLS or
the macOS keychain may need `Security`.

## Java

The JVM uses its own TLS implementation (JSSE), so pure Java does not need
Darwin frameworks. JNI code that calls into the macOS Security framework
(e.g. for keychain access) needs `Security`.

## PHP

PHP extensions compiled with macOS system library support may need `Security`.
The `openssl` extension on Darwin may use the system trust store via
`Security`.

## Ruby

Ruby C extensions that use the macOS keychain or system TLS need `Security`.
The `openssl` gem on Darwin may need `Security` for access to the system trust
store.

## General pattern

The optional Darwin-only additions can be appended to `buildInputs` using
`stdenv.isDarwin`:

```nix
buildInputs =
  [ pkgs.openssl ]
  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.libiconv
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
  ];
```

When this is missing, the build fails with a linker error mentioning
`framework Security` or `framework SystemConfiguration`.

The older `darwin.apple_sdk_11_0` compatibility stub has been removed from
nixpkgs; that is a separate error from `darwin.apple_sdk.frameworks.Security`,
which is still the correct attribute to use for framework linking.

## When to add Darwin frameworks

**Add them when:**

1. The project links against macOS system TLS (not bundled OpenSSL/BoringSSL).
2. The project accesses the macOS keychain.
3. The build fails with `framework not found Security` or
   `framework not found SystemConfiguration`.
4. The language runtime uses system frameworks natively (Swift, .NET).

**Do NOT add them when:**

1. The language bundles its own TLS (pure Go, Node.js pure JS, JVM with JSSE).
2. The build succeeds without them.
