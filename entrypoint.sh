#! /bin/sh

set -eo pipefail

if [ -z "${POSTGRES_USER}" ]; then
  echo "Please set POSTGRES_USER"
  exit 1
fi

if [ -z "${POSTGRES_PASSWORD}" ]; then
  echo "Please set POSTGRES_PASSWORD"
  exit 1
fi

if [ -z "${POSTGRES_DB}" ]; then
  echo "Please set POSTGRES_DB"
  exit 1
fi

if [ -z "${S3_ACCESS_KEY_ID}" ]; then
  echo "Please set S3_ACCESS_KEY_ID"
  exit 1
fi

if [ -z "${S3_SECRET_ACCESS_KEY}" ]; then
  echo "Please set S3_SECRET_ACCESS_KEY"
  exit 1
fi

if [ -z "${S3_BUCKET}" ]; then
  echo "Please set S3_BUCKET"
  exit 1
fi

if [ -z "${S3_PATH}" ]; then
  echo "Please set S3_PATH"
  exit 1
fi

if [ -z "${S3_FILENAME}" ]; then
  echo "Please set S3_FILENAME"
  exit 1
fi

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

pg_dump --version
pg_restore --version

if [ -z "${SCHEDULE}" ]; then
  sh backup.sh
else
  exec go-cron -s "$SCHEDULE" -p 1880 -- /bin/sh ./backup.sh
fi
