#!/bin/bash

if [ -z $WATERFALL_VERSION ]; then
    WATERFALL_VERSION="1.16"
fi
if [ -z $WATERFALL_JAR_NAME ]; then
    WATERFALL_JAR_NAME="waterfall.jar"
fi
if [ -z $WATERFALL_START_MEMORY ]; then
    WATERFALL_START_MEMORY="512M"
fi
if [ -z $WATERFALL_MAX_MEMORY ]; then
    WATERFALL_MAX_MEMORY="512M"
fi
if [ -z $WATERFALL_UPDATE_SECONDS ]; then
    WATERFALL_UPDATE_SECONDS=86400
fi

trap shutdown_message INT
function shutdown_message() {
    WATERFALL_SHUTDOWN=1
}

lastmod() {
    expr `date +%s` - `stat -c %Y $1`
}

while (( "$#" )); do
  case "$1" in
    --skip-update)
      WATERFALL_SKIP_UPDATE=1
      shift
      ;;
    --auto-restart)
      AUTO_RESTART=1
      shift
      ;;
    --version)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        WATERFALL_VERSION=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --jar-name)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        WATERFALL_JAR_NAME=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -ms|--start-memory)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        WATERFALL_MIN_MEMORY=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -mx|--max-memory)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        WATERFALL_MAX_MEMORY=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --max-players)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        WATERFALL_MAX_PLAYERS=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "ERROR: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

eval set -- "$PARAMS"

WATERFALL_DOWNLOAD_URL="https://papermc.io/api/v1/waterfall/${WATERFALL_VERSION}/latest/download"

function update_waterfall() {
    if ! [ -f "$WATERFALL_JAR_NAME" ]; then
        echo "Downloading Waterfall ${WATERFALL_DOWNLOAD_URL} -> ${WATERFALL_JAR_NAME}..."
        echo "> curl -s -o ${WATERFALL_JAR_NAME} ${WATERFALL_DOWNLOAD_URL}"
        curl -s -o ${WATERFALL_JAR_NAME} ${WATERFALL_DOWNLOAD_URL}
    else
        if [ -z $WATERFALL_SKIP_UPDATE ]; then
            SEC_SINCE_UPDATE=$(lastmod ${WATERFALL_JAR_NAME})

            if [ "$SEC_SINCE_UPDATE" -gt "$WATERFALL_UPDATE_SECONDS" ]; then
                rm ${WATERFALL_JAR_NAME}
                echo "Updating Waterfall ${WATERFALL_DOWNLOAD_URL} -> ${WATERFALL_JAR_NAME}..."
                echo "> curl -s -o ${WATERFALL_JAR_NAME} ${WATERFALL_DOWNLOAD_URL}"
                curl -s -o ${WATERFALL_JAR_NAME} ${WATERFALL_DOWNLOAD_URL}
            else
                echo "Skipping Waterfall update, ${SEC_SINCE_UPDATE} !> ${WATERFALL_UPDATE_SECONDS}..."
            fi
        else
            echo "Skipping Waterfall update, skip flag..."
        fi
    fi

    if ! [ -z $WATERFALL_SHUTDOWN ]; then
        echo "ERROR: Download cancelled, cleaning up..."
        rm ${WATERFALL_JAR_NAME}
        exit 1
    fi
}

function start_waterfall() {
    echo "> java -Xms${WATERFALL_START_MEMORY} -Xmx${WATERFALL_MAX_MEMORY} ${WATERFALL_JAVA_ARGS} -jar ${WATERFALL_JAR_NAME} ${WATERFALL_ARGS} ${PARAMS}"
    java -Xms${WATERFALL_START_MEMORY} -Xmx${WATERFALL_MAX_MEMORY} ${WATERFALL_JAVA_ARGS} -jar ${WATERFALL_JAR_NAME} ${WATERFALL_ARGS} ${PARAMS}
}

if [ -z $AUTO_RESTART ]; then
    update_waterfall

    echo "Starting Waterfall server..."
    start_waterfall
else
    while [ -z $WATERFALL_SHUTDOWN ]; do 
        update_waterfall

        echo "Starting Waterfall server, auto-restart enabled..."
        start_waterfall
        sleep 3
    done
fi

echo "Waterfall server shutdown."