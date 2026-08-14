:::code-group

```bash [npm]
npm install -g <package-name>
```

```bash [Homebrew]
brew install <formula>
```

```bash [Nix]
# Latest (default branch or latest release)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Specific version
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3

# Or choose an output: #latest, #source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#latest
```

:::
