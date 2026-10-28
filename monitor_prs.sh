#!/usr/bin/env bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/agent-approval-probe

echo "watching PR-A(2 claim-bypass) PR-B(1 legit-exempt) PR-C(3 negative-control) for workflow completion + commit status + mergeability"

j=0
while true; do
  all_done=true
  for pr in 1 2 3; do
    status=$(gh pr view "$pr" --json statusCheckRollup --jq '.statusCheckRollup[0].status // "none"' 2>/dev/null)
    if [ "$status" != "COMPLETED" ]; then
      all_done=false
    fi
  done
  j=$((j+1))
  if [ $((j % 6)) -eq 0 ] || [ "$all_done" == "true" ]; then
    echo "poll $j: PR1=$(gh pr view 1 --json statusCheckRollup --jq '.statusCheckRollup[0].status // "none"' 2>/dev/null) PR2=$(gh pr view 2 --json statusCheckRollup --jq '.statusCheckRollup[0].status // "none"' 2>/dev/null) PR3=$(gh pr view 3 --json statusCheckRollup --jq '.statusCheckRollup[0].status // "none"' 2>/dev/null)"
  fi
  if [ "$all_done" == "true" ]; then
    break
  fi
  sleep 15
done

echo "--- ALL WORKFLOWS COMPLETED, final results ---"
for pr in 1 2 3; do
  echo "=== PR #$pr ==="
  gh pr view "$pr" --json number,title,headRefName,url,mergeable,mergeStateStatus,statusCheckRollup
  echo
done
echo "MONITOR_DONE"
