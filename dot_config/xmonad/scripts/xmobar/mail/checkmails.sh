#!/usr/bin/env bash

GMAIL=`ls -l ~/Mail/Gmail/INBOX/new/ | grep ^- | wc -l`
NEXUS=`ls -l ~/Mail/Nexus/INBOX/new/ | grep ^- | wc -l`

COUNT=$(($GMAIL+$NEXUS))

echo $COUNT
