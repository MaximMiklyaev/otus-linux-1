#!/bin/bash

LOCKFILE=/home/user/lockfile.lock

if [ -f $LOCKFILE ]
then
  echo "Lockfile active, no new runs."
  exit 1 
else
  echo "PID: $$" > $LOCKFILE
  trap 'rm -f $LOCKFILE"; exit $?' INT TERM EXIT
  echo "Simulate some activity..."
  rm -f $LOCKFILE
  trap - INT TERM EXIT
fi
