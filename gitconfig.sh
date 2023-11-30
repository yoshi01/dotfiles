#!/bin/bash
GIT_CONFIG_PATH=~/.gitconfig

GIT_ALIASES="[alias]
  st = status
  ad = add
  aa = add -A
  ap = add -p
  us = reset HEAD .
  br = branch
  ba = branch -a
  bd = branch -d
  bm = branch -m
  co = checkout
  cof = checkout --force
  cop = checkout -
  m = checkout main
  cm = commit -m
  cma = commit --amend
  cmm = commit --amend -m
  cmp = commit --allow-empty -m \"make pull request\"
  ft = fetch
  fp = fetch -p
  ss = stash
  sc = stash clear
  sl = stash list
  sp = stash pop
  sa = stash apply stash@{0}
  pl = pull
  ps = push
  ph = push origin HEAD
  la = log --oneline --graph --decorate --all
  lg = log --oneline --graph --decorate
  lp= log --pretty='format:%C(yellow)%h%Creset %C(magenta)%cd%Creset %s %Cgreen(%an)%Creset %Cred%d%Creset' --date=iso --graph
  ln= log --pretty=full
  lb = !\"f() { git --no-pager reflog | awk '$3 == \"checkout:\" && /moving from/ {print $8}' | uniq | head; }; f\"
  lpr = !\"f() { git log --merges --oneline --reverse --ancestry-path $1...master | grep 'Merge pull request #' | head -n 1; }; f\"
  gr = grep
  df = diff
  dh = diff HEAD^ HEAD
  ds = diff --cached
  rs = reset --soft HEAD^
  rh = reset --hard HEAD^
  rw = reset --hard HEAD
  rv = revert
  rvm = revert -m 1
  rb = rebase
  rbi = rebase -i
  rbc = rebase --continue
  rba = rebase --abort
  cn = clean -n
  cl = clean -df
  cp = cherry-pick
  cf = config --list
  cfg = config --global --edit
  cfl = config --local --edit"

if ! grep -q "\[alias\]" "$GIT_CONFIG_PATH"; then
    echo "$GIT_ALIASES" >> "$GIT_CONFIG_PATH"
    echo "Aliases added to $GIT_CONFIG_PATH"
else
    echo "Aliases already exist in $GIT_CONFIG_PATH. Skipping..."
fi
