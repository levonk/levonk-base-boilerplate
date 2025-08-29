#!/bin/bash

###
# This script enforces the custom 'executable' attribute in .gitattributes.
# First it checks if its on WSL or VirtualBox Windows mount to skip the enforcement.
# It checks if the file is executable and if the .gitattributes file has the executable attribute set.
# If the file is executable and the .gitattributes file has the executable attribute set, it will exit with a non-zero status.
# If the file is not executable and the .gitattributes file has the executable attribute set, it will exit with a non-zero status.
# If the file is executable and the .gitattributes file does not have the executable attribute set, it will exit with a non-zero status.
# If the file is not executable and the .gitattributes file does not have the executable attribute set, it will exit with a non-zero status.
###

# Detect mount quirks
IS_WSL=$(grep -qi microsoft /proc/version && echo true)
IS_VBOX=$(mount | grep -qi vboxsf && echo true)

# Get staged files
FILES=$(git diff --cached --name-only)

for FILE in $FILES; do
  [ -f "$FILE" ] || continue

  # Get declared executable attribute
  ATTR=$(git check-attr executable -- "$FILE" | awk '{print $3}')

  # Skip if not set
  [[ "$ATTR" == "unspecified" ]] && continue

  # Check actual mode
  IS_EXEC=$(test -x "$FILE" && echo true || echo false)

  # Compare and warn
  if [[ "$ATTR" == "false" && "$IS_EXEC" == "true" ]]; then
    echo "⚠️ '$FILE' is executable but marked 'executable=false' in .gitattributes."
    if [[ "$IS_WSL" == "true" || "$IS_VBOX" == "true" ]]; then
      echo "🔍 Detected WSL or VirtualBox mount—mode bits may be unreliable. Skipping enforcement."
    else
      echo "👉 Consider running: chmod -x '$FILE'"
      exit 1
    fi
  fi

  if [[ "$ATTR" == "true" && "$IS_EXEC" == "false" ]]; then
    echo "⚠️ '$FILE' is not executable but marked 'executable=true'."
    if [[ "$IS_WSL" == "true" || "$IS_VBOX" == "true" ]]; then
      echo "🔍 Detected WSL or VirtualBox mount—mode bits may be unreliable. Skipping enforcement."
    else
      echo "👉 Consider running: chmod +x '$FILE'"
      exit 1
    fi
  fi
done

exit 0