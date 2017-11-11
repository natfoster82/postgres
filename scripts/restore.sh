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

FILENAME=${1:-latest}

echo "Restoring from $FILENAME"

s3cmd get s3://${S3_BUCKET}/${POSTGRES_DB}/$FILENAME --force

psql postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost/${POSTGRES_DB} << EOF
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
EOF

pg_restore -d postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost/${POSTGRES_DB} < $FILENAME

rm "$FILENAME"