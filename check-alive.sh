#!/bin/bash -xe

PROGNAME=$(basename $0)
VERSION="0.9.0"

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
TIMESTAMP=$(date --iso-8601=seconds --utc)

NAMESPACE="System/Linux"
DIMENSIONS="InstanceId=$INSTANCE_ID"

usage() {
    echo "Usage: $PROGNAME [OPTIONS] FILE"
    echo "  This script checks if a certain process is alive."
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "      --version"
    echo "      --with-port PORT_NUMBER"
    echo "      --with-process PROCESS_NAME"
    echo "      --with-http HTTP_PORT_NUMBER"
    echo
}

for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 0
            ;;
        '--version' )
            echo $VERSION
            exit 1
            ;;
        '--with-port' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            job="port"
            arg="$2"
            shift 2
            ;;
        '--with-process' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            job="process"
            arg="$2"
            shift 2
            ;;
        '--with-http' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            job="http"
            arg="$2"
            shift 2
            ;;
        '--'|'-' )
            shift 1
            param+=( "$@" )
            break
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                param+=( "$1" )
                shift 1
            fi
            ;;
    esac
done

function port_check() {
    port_num=$1
    process_count=$(netstat -tapn | awk '{ print $4 }' | grep ":$port_num$" | wc -l)

    aws cloudwatch put-metric-data --metric-name ListinigPortsFor_${port_num} --namespace $NAMESPACE --dimensions $DIMENSIONS --value $process_count --unit Count --timestamp $TIMESTAMP
}

function process_check() {
    process_name=$1
    pids=$(pgrep -l $process_name | wc -l)

    aws cloudwatch put-metric-data --metric-name ${process_name}ProcessCount --namespace $NAMESPACE --dimensions $DIMENSIONS --value $pids --unit Count --timestamp $TIMESTAMP
}

function http_check() {
    port_num=$1
    status=$(curl -s -w '%{http_code}\n' "http://localhost:${port_num}/ping" -o /dev/null) || true

    value=0
    if [ -n $status ] && [ $status -eq 200 ]; then
        value=1
    fi
    aws cloudwatch put-metric-data --metric-name HTTPHealthFor_${port_num} --namespace $NAMESPACE --dimensions $DIMENSIONS --value $value --unit Count --timestamp $TIMESTAMP
}

case "$job" in
    'port')
        port_check $arg
        exit 0
        ;;
    'process')
        process_check $arg
        exit 0
        ;;
    'http')
        http_check $arg
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac
