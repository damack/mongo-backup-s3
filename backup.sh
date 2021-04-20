#!/bin/sh
file=$(date -u +"%Y-%m-%dT%H-%MZ")
start=$(date -d "yesterday" -u +"%Y-%m-%dT00:00:00Z")
end=$(date -d "yesterday" -u +"%Y-%m-%dT23:59:59Z")

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${MONGODB_HOST}" = "**None**" ]; then
  echo "You need to set the MONGODB_HOST environment variable."
  exit 1
fi

if [ "${MONGODB_USER}" = "**None**" ]; then
  echo "You need to set the MONGODB_USER environment variable."
  exit 1
fi

if [ "${MONGODB_PASS}" = "**None**" ]; then
  echo "You need to set the MONGODB_PASS environment variable."
  exit 1
fi

if [ "${MONGODB_DB}" = "**None**" ]; then
  echo "You need to set the MONGODB_DB environment variable."
  exit 1
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

for COLLACTION in $COLLACTIONS_FULL
do
    echo "Dump $COLLACTION"
    mongodump --host $MONGODB_HOST --username $MONGODB_USER --password $MONGODB_PASS --authenticationDatabase admin -d=$MONGODB_DB -c=$COLLACTION --out /backup
done

for COLLACTION in $COLLACTIONS_LAST_DAY
do
    echo "Dump $COLLACTION"
    mongodump --host $MONGODB_HOST --username $MONGODB_USER --password $MONGODB_PASS --authenticationDatabase admin -d=$MONGODB_DB -c=$COLLACTION -q='{"createdAt":{"$gt": {"$date":"'$start'"}, "$lte": {"$date":"'$end'"}}}' --out /backup
done
echo $start
echo $end

echo "Uploading dump to $S3_BUCKET"
tar cfz "/backup/$file.tar.gz" /backup
aws s3 cp "/backup/$file.tar.gz" s3://$S3_BUCKET/$S3_PREFIX/$file.tar.gz
rm -rf /backup/$MONGODB_DB
rm /backup/$file.tar.gz
echo "MongoDB backup uploaded successfully"