#!/bin/bash

if [ "x$REPLICATE_FROM" == "x" ]; then

cat >> ${PGDATA}/postgresql.conf <<EOF
wal_level = hot_standby
max_wal_senders = $PG_MAX_WAL_SENDERS
wal_keep_segments = $PG_WAL_KEEP_SEGMENTS
hot_standby = on
EOF

else

cat > ${PGDATA}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=${REPLICATE_FROM} port=5432 user=${POSTGRES_USER} password=${POSTGRES_PASSWORD}'
trigger_file = '/tmp/make_me_master'
EOF
chown postgres ${PGDATA}/recovery.conf
chmod 600 ${PGDATA}/recovery.conf

fi

#
# main entry point to run s3cmd
#
S3CMD_CONFIG=/root/.s3cfg

#
# Check for required parameters
#
if [ -z "${S3_ACCESS_KEY_ID}" ]; then
    echo "ERROR: The environment variable key is not set."
    exit 1
fi

if [ -z "${S3_SECRET_ACCESS_KEY}" ]; then
    echo "ERROR: The environment variable secret is not set."
    exit 1
fi
#
# Set user provided key and secret in .s3cfg file
#
echo "" >> "$S3CMD_CONFIG"
echo "access_key=${S3_ACCESS_KEY_ID}" >> "$S3CMD_CONFIG"
echo "secret_key=${S3_SECRET_ACCESS_KEY}" >> "$S3CMD_CONFIG"
echo "gpg_passphrase=${S3_PASSPHRASE}" >> "$S3CMD_CONFIG"
#
# Finished operations
#
echo "Finished s3cmd operations"


#if [ "x${RESTORE_FROM}" != "x" ] && [ "x$REPLICATE_FROM" == "x" ]; then

#echo "Restoring from ${RESTORE_FROM}"
#s3cmd get s3://${S3_BUCKET}/${POSTGRES_DB}/${RESTORE_FROM} --force
#pg_restore -d postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost/${POSTGRES_DB} < ${RESTORE_FROM}
#rm "${RESTORE_FROM}"

#fi