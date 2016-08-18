#!/bin/sh

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
TIMESTAMP=$(date --iso-8601=seconds --utc)

NAMESPACE="System/Linux"
DIMENSIONS="InstanceId=$INSTANCE_ID"

PREFIX="$1"
PATTERN="$2"

pids=$(pgrep -l $PATTERN | wc -l)

aws cloudwatch put-metric-data --metric-name ${PREFIX}ProcessCount --namespace $NAMESPACE --dimensions $DIMENSIONS --value $pids --unit Count --timestamp $TIMESTAMP
