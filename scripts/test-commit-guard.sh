#!/bin/sh
set -eu

project=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
hook="$project/.githooks/pre-commit"
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' 0
trap 'exit 130' INT
trap 'exit 143' TERM

git init --quiet "$temporary/repo"
cd "$temporary/repo"
cp "$project/.gitignore" .gitignore
git add .gitignore

check() {
  if sh "$hook" >"$temporary/check-output" 2>&1; then
    status=0
  else
    status=$?
  fi
  if [ "$status" -ne "$1" ]; then
    printf 'FAIL: %s (expected exit %s, got %s)\n' "$2" "$1" "$status" >&2
    sed -n '1,30p' "$temporary/check-output" >&2
    exit 1
  fi
  printf 'PASS: %s\n' "$2"
}

printf '# Public slide notes\nSource: assets/example.svg\n' >sample.md
git add sample.md
check 0 'portable public content'

printf '/%s/%s/project/slides.md\n' Users example >sample.md
git add sample.md
check 1 'macOS home path'

printf '/%s/%s/project/slides.md\n' home example >sample.md
git add sample.md
check 1 'Linux home path'

printf 'C:\\%s\\%s\\slides.md\n' Users example >sample.md
git add sample.md
check 1 'Windows home path'

printf '%s:///%s/slides.md\n' file example >sample.md
git add sample.md
check 1 'local file URL'

printf '%s%s%s\n' '-----BEGIN ' 'PRIVATE KEY' '-----' >sample.md
git add sample.md
check 1 'private key header'

printf '%s_%032d\n' ghp 0 >sample.md
git add sample.md
check 1 'synthetic GitHub token'

printf '%s=%s\n' api_key not-a-real-secret >sample.md
git add sample.md
check 1 'literal credential assignment'

printf '%s=%s\n' AWS_SECRET_ACCESS_KEY not-a-real-secret >sample.md
git add sample.md
check 1 'prefixed environment credential assignment'

printf '%s://%s:%s@%s\n' https user not-a-real-secret example.test >sample.md
git add sample.md
check 1 'credentials in a URL'

printf '# Clean working copy, unsafe index\n' >sample.md
check 1 'staged content is checked even if the working copy is clean'

git add sample.md
printf '%s_%032d\n' ghp 0 >sample.md
check 0 'unstaged content does not alter the staged-content result'

printf 'private test configuration\n' >.env
git add --force .env
check 1 'force-added ignored file'

printf 'All commit-guard tests passed.\n'
