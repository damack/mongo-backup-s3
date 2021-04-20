FROM alpine:latest

RUN apk update && apk add mongodb-tools python3 py3-pip && pip3 install awscli && rm -rf /var/cache/apk/*

ENV MONGODB_HOST **None**
ENV MONGODB_PORT **None**
ENV MONGODB_USER 27017
ENV MONGODB_PASS **None**
ENV COLLACTIONS_FULL **None**
ENV COLLACTIONS_LAST_DAY **None**
ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_REGION us-west-1
ENV S3_PATH 'backup'

ADD backup.sh backup.sh

CMD ["sh", "backup.sh"]
