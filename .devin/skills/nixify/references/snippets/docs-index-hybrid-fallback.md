:::code-group

```bash [npm]
npm install -g <package-name>
```

```bash [Homebrew]
brew install <formula>
```

```bash [Nix]
# Latest release (auto-bumped daily, prebuilt where available, source fallback)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Or choose explicitly: #prebuilt (fast, platform-limited) or #source (any platform)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

:::
