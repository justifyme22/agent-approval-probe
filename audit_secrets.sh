#!/usr/bin/env bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/agent-approval-probe

echo '=== all tracked files ==='
git ls-files

echo '=== full git log, all branches ==='
git log --all --oneline

echo '=== full content of every tracked file ==='
git ls-files | while read -r f; do
  echo "--- $f ---"
  cat "$f"
  echo
done

echo '=== grep for common secret patterns across all history ==='
git log --all -p | grep -iE 'api[_-]?key|secret|token|password|credential|BEGIN (RSA|OPENSSH|PRIVATE)|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}' || echo 'NO MATCHES FOUND'
