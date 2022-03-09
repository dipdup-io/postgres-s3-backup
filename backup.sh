#! /bin/sh

set -eo pipefail
set -o pipefail

if [ -z "${POSTGRES_HOST}" ]; then  
  POSTGRES_HOST="db"
fi

if [ -z "$POSTGRES_PORT" ]; then
  POSTGRES_PORT="5432"
fi

if [ -z "${S3_ENDPOINT}" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

# env vars needed for pg_dump
export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"

case "${PG_BACKUP_ACTION:-dump}" in
  dump)
    # TODO: check if database is fresh
    echo "Snapshotting $POSTGRES_DB database"
    pg_dump -Fc $POSTGRES_HOST_OPTS $POSTGRES_DB > dump.backup

    echo "Rotating old snapshot"
    aws $AWS_ARGS s3 cp s3://$S3_BUCKET/$S3_PATH/$S3_FILENAME.backup s3://$S3_BUCKET/$S3_PATH/$S3_FILENAME.old.backup --acl public-read || true

    echo "Uploading fresh snapshot to $S3_BUCKET/$S3_PATH/$S3_FILENAME"
    cat dump.backup | aws $AWS_ARGS s3 cp - s3://$S3_BUCKET/$S3_PATH/$S3_FILENAME.backup --acl public-read || exit 2

    echo "Snapshot uploaded successfully, removing local file"
    rm dump.backup

    if [ ! -z "$HEARTBEAT_URI" ]; then
      echo "Sending heartbeat signal"
      curl -m 10 --retry 5 $HEARTBEAT_URI
    fi
    ;;
  restore)
    if [ -z "${PG_BACKUP_FILE}" ]; then
      echo "Please set PG_BACKUP_FILE variable"
      exit 1
    fi

    echo "Downloading latest snapshot from $PG_BACKUP_FILE"
    curl -o dump.backup $PG_BACKUP_FILE

    echo "Restoring $POSTGRES_DB database"
    pg_restore -c -C -d $POSTGRES_DB $POSTGRES_HOST_OPTS dump.backup
    ;;
esac