set -e

if [ -z "$__DEVBOX_SKIP_INIT_HOOK_dd7543c3a631e59e6f2e4773bfaa1ff9a062bdeeefbd79093d9985c8093db80c" ]; then
    . "/Users/micro/p/gh/levonk/levonk-base-boilerplate/test-typescript-cli/.devbox/gen/scripts/.hooks.sh"
fi

prettier --check .
