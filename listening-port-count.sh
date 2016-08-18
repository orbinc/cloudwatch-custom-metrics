#!/bin/sh

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
TIMESTAMP=$(date --iso-8601=seconds --utc)

NAMESPACE="System/Linux"
DIMENSIONS="InstanceId=$INSTANCE_ID"

PREFIX="$1"
PORT="$2"

listening_ports=$(sudo lsof -tiTCP:"$PORT" | wc -l)

aws cloudwatch put-metric-data --metric-name ListinigPortsFor_${PREFIX} --namespace $NAMESPACE --dimensions $DIMENSIONS --value $listening_ports --unit Count --timestamp $TIMESTAMP
