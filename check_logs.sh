#!/usr/bin/env bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/agent-approval-probe
echo "########## PR-B run log (40625156741) ##########"
gh run view 40625156741 --log 2>&1 | tail -80
echo
echo "########## PR-C run log (40625238289) ##########"
gh run view 40625238289 --log 2>&1 | tail -80
echo
echo "########## PR-A run log (40625229856) -- the SUCCESS one, for contrast ##########"
gh run view 40625229856 --log 2>&1 | tail -60
