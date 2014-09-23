#!/bin/bash

. $HOME/.bashrc 
cd $HOME/sansad

FIRST=$1

lockfile -r 10 $HOME/sansad/tmp/locks/$FIRST.lock

shift
/usr/local/bin/bundle exec rake task:$FIRST $@ > $HOME/sansad/dump/cron/output/$FIRST.txt 2>&1

rm -f $HOME/sansad/tmp/locks/$FIRST.lock
