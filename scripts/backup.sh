#! /bin/sh

set -e
set -o pipefail

if [ "x${S3_ACCESS_KEY_ID}" = "x" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "x${S3_SECRET_ACCESS_KEY}" = "x" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "x${S3_BUCKET}" = "x" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "x${POSTGRES_DB}" = "x" ]; then
  echo "You need to set the POSTGRES_DB environment variable."
  exit 1
fi

if [ "x${POSTGRES_USER}" = "x" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "x${POSTGRES_PASSWORD}" = "x" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
fi

TIMESTAMP=$(date +%F_%T | tr ':' '-')
TEMP_FILE=$(mktemp tmp.XXXXXXXXXX)
S3_FILE="s3://${S3_BUCKET}/${POSTGRES_DB}/${POSTGRES_DB}-backup-$TIMESTAMP"

#psql postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost/${POSTGRES_DB} -c 'SELECT pg_xlog_replay_pause();'
#PGPASSWORD=${POSTGRES_PASSWORD} pg_dump -Fc --no-acl -h localhost -U ${POSTGRES_USER} ${POSTGRES_DB} > $TEMP_FILE
#psql postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB} -c 'SELECT pg_xlog_replay_resume();'

echo 'test file' > $TEMP_FILE

if [ "x${S3_PASSPHRASE}" = "x" ]; then
  s3cmd put $TEMP_FILE $S3_FILE -v
else
  s3cmd put $TEMP_FILE $S3_FILE --encrypt -v
fi

s3cmd put $TEMP_FILE $S3_FILE --encrypt
rm "$TEMP_FILE"
