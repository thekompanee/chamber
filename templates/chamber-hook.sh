#!/bin/bash

echo "Checking for RVM"
if [ -d "$HOME/.rvm/bin" ]; then
  PATH="$HOME/.rvm/bin:$PATH"
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
 
  if [ -f ".ruby-version" ]; then
    rvm use "$(cat .ruby-version)"
  fi
 
  if [ -f ".ruby-gemset" ]; then
    rvm gemset use "$(cat .ruby-gemset)"
  fi
fi
echo "Running chamber secure command"
chamber secure
