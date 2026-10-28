#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd ~/agent-approval-probe

echo "=== repo visibility check ==="
gh repo view justifyme22/agent-approval-probe --json visibility

echo "=== branch protection: require ONLY the agent-approval-check status, no required reviewers ==="
gh api -X PUT "repos/justifyme22/agent-approval-probe/branches/main/protection" \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": false,
    "contexts": ["agent-approval-check"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null
}
EOF

echo "=== PR-B: legitimate exempt control (docs/readme.md) ==="
git checkout main
git pull origin main
git checkout -b pr-b-legit-exempt
echo "legit docs change $(date -u +%s 2>/dev/null || echo marker)" >> docs/readme.md
git -c user.email="noreply@anthropic.com" -c user.name="agent-approval-probe-bot" add -A
git -c user.email="noreply@anthropic.com" -c user.name="agent-approval-probe-bot" \
  commit -m "touch docs/readme.md (agent-authored commit, genuinely under docs/)"
git push -u origin pr-b-legit-exempt
gh pr create --base main --head pr-b-legit-exempt \
  --title "PR-B: legitimate-exempt-control (docs/readme.md)" \
  --body "Live validation test. Expected: exempt, success, this IS the intended correct use of exempt_path_prefixes."

echo "PHASE2_DONE"
gh pr list --json number,title,headRefName,url
