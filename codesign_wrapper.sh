#!/bin/bash
# Wrapper that strips xattrs before calling real codesign
# Workaround for macOS Sequoia com.apple.provenance bug
for arg in "$@"; do
  if [[ -e "$arg" && ! "$arg" == -* ]]; then
    xattr -cr "$arg" 2>/dev/null
  fi
done
/usr/bin/codesign "$@"
