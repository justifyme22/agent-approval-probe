#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd ~/agent-approval-probe

echo "=== fix workflow permissions on main: pull-requests write ==="
git checkout main
git pull origin main
sed -i 's/pull-requests: read/pull-requests: write/' .github/workflows/agent-approval-check.yml
cat .github/workflows/agent-approval-check.yml
git -c user.email="noreply@anthropic.com" -c user.name="agent-approval-probe-bot" add -A
git -c user.email="noreply@anthropic.com" -c user.name="agent-approval-probe-bot" \
  commit -m "fix: grant pull-requests:write (needed for the non-exempt path's notification mutation)"
git push origin main

echo "=== fix PR-B: redo cleanly without the scratch-file contamination ==="
git checkout pr-b-legit-exempt
git merge main --no-edit -m "merge main (permission fix) into pr-b-legit-exempt"
# remove the accidentally-committed scratch files from THIS branch too
git rm -f audit_secrets.sh make_public.sh phase2.sh 2>&1 || true
git -c user.email="noreply@anthropic.com" -c user.name="agent-approval-probe-bot" add -A
git -c user.email="noreply@anthropic.com" -c user.name="agent-approval-probe-bot" \
  commit -m "cleanup: remove scratch files so this PR only touches docs/readme.md" --allow-empty
git push origin pr-b-legit-exempt

echo "=== trigger PR-C re-run with fixed permissions (empty commit) ==="
git checkout pr-c-negative-control
git merge main --no-edit -m "merge main (permission fix) into pr-c-negative-control"
git push origin pr-c-negative-control

echo "=== files now in each PR, for the record ==="
echo "--- PR-B diff vs main ---"
git diff main...pr-b-legit-exempt --stat
echo "--- PR-C diff vs main ---"
git diff main...pr-c-negative-control --stat

echo "PHASE4_DONE"
