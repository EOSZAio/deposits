#!/bin/bash

# Edit this path to hold the absolute path to the scripts folder. Nodeos won't run correctly if a absolute path is not specified
HOME=/Users/rory/TCD/exchange-deposits/scripts
NODEOS=$HOME/nodeos
DATADIR=$NODEOS/data

$HOME/stop.sh

#rm -r $NODEOS/*

rm $NODEOS/nodeos.log
rm $NODEOS/nodeos.pid
rm $NODEOS/nodeos.tty
rm -r $NODEOS/data
rm -r $NODEOS/protocol_features

$HOME/start.sh
