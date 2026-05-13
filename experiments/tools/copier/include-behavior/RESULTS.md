# Copier Include Permutations Test Results

## Test Summary

We tested 3 different patterns for including partial templates in Copier:

### Test 1: Root _partials ✅ WORKS (but copies _partials)
- **Structure**: `_partials/test-partial.jinja` at root
- **Include**: `{% include "_partials/test-partial.jinja" %}`
- **Result**: ✅ Template renders successfully
- **Problem**: ❌ `_partials` directory is copied to output
- **Files created**: `template`, `_partials/test-partial`

### Test 2: copier/_partials ✅ WORKS (but copies _partials)
- **Structure**: `copier/_partials/test-partial.jinja`
- **Include**: `{% include "copier/_partials/test-partial.jinja" %}`
- **Result**: ✅ Template renders successfully
- **Problem**: ❌ `copier/_partials` directory is copied to output
- **Files created**: `template`, `copier/_partials/test-partial`

### Test 3: files/_partials ❌ FAILS
- **Structure**: `files/_partials/test-partial.jinja` with `_subdirectory: files`
- **Include**: `{% include "_partials/test-partial.jinja" %}`
- **Result**: ❌ `TemplateNotFound: '_partials/test-partial.jinja'`
- **Problem**: Copier cannot find partials when using `_subdirectory`

## Key Findings

1. **Root-level includes work** but copy the `_partials` directory to output
2. **Nested includes work** but also copy the directory structure
3. **Using `_subdirectory: files` breaks includes** - Copier cannot find partials

## The Solution

Based on the working `docker-linux` template pattern, the correct approach is:

1. **Use `_subdirectory: files`** in `copier.yml`
2. **Put partials in `files/partials/` WITHOUT `.jinja` extension**
3. **Include as `{% include "partials/filename" %}`**
4. **Files without `.jinja` extension are included during rendering but NOT copied to output**

This pattern:
- ✅ Prevents `_partials` directory from being copied
- ✅ Allows includes to work properly
- ✅ Follows Copier best practices

## Example Working Structure

```
docker-linux/
├── copier.yml          # contains `_subdirectory: files`
└── files/
    ├── partials/
    │   ├── env-core          # NO .jinja extension
    │   └── docker-service    # NO .jinja extension
    └── docker-compose.yml.jinja
```

Include in template:
```jinja
{% include "partials/env-core" %}
```
