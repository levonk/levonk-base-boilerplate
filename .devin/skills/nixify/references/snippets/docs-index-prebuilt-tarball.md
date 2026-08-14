:::code-group

```bash [npm]
npm install -g <package-name>
```

```bash [Homebrew]
brew install <formula>
```

```bash [Nix]
# Latest release (auto-bumped daily, prebuilt)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Or choose explicitly: #prebuilt (fast) or #source (from source)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

:::
