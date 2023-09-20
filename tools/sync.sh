#!/bin/bash

set -e

echo "1. Remove all files and directories except the specified ones"
for item in *; do
  if [ "$item" != "tools" ] &&
    [ "$item" != "shims" ] &&
    [ "$item" != "README.md" ] &&
    [ "$item" != "go.mod" ] &&
    [ "$item" != "cfcrypto.go" ]; then
    rm -rf "$item"
  fi
done

echo "2. Clone the repository into a temporary directory"
temp_dir=$(mktemp -d)
git clone --depth 1 https://github.com/cloudflare/go "$temp_dir"

echo "3. Copy files from src/crypto to the current directory"
cp -r "$temp_dir/src/crypto/tls" ./

echo "4. Remove test files and unnecessary packages"
rm -rf tls/*_test.go
rm -rf tls/fipsonly
rm -rf tls/testdata
grep -rl '//go:build boringcrypto' . | grep -v '^./tools/sync.sh$' | xargs rm -f

echo "5. Replaces some packages with shims"

# Replacing some imports with shims
replaceShims() {
  # Detect OS
  os=$(uname)

  if [ "$os" == "Darwin" ]; then
    # macOS
    find . -type f -name "*.go" -exec sed -i '' -e 's|"crypto/internal/boring"|"github.com/ameshkov/cfcrypto/shims/boring"|g' {} +
    find . -type f -name "*.go" -exec sed -i '' -e 's|"internal/godebug"|"github.com/ameshkov/cfcrypto/shims/godebug"|g' {} +
    find . -type f -name "*.go" -exec sed -i '' -e 's|"internal/cpu"|"golang.org/x/sys/cpu"|g' {} +
  else
    # Linux
    find . -type f -name "*.go" -exec sed -i -e 's|"crypto/internal/boring"|"github.com/ameshkov/cfcrypto/shims/boring"|g' {} +
    find . -type f -name "*.go" -exec sed -i -e 's|"internal/godebug"|"github.com/ameshkov/cfcrypto/shims/godebug"|g' {} +
    find . -type f -name "*.go" -exec sed -i -e 's|"internal/cpu"|"golang.org/x/sys/cpu"|g' {} +
  fi
}

# Replace with shims
replaceShims

echo "6. Remove the temporary directory with the cloned repository"
rm -rf "$temp_dir"

echo "7. Check that everything is in order"
go build
go mod tidy
go test ./...

echo "8. Done!"
