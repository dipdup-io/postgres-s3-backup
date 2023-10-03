FROM google/cloud-sdk:a448.0.0-alpine

RUN apk update \
    && apk --no-cache add dumb-init postgresql-client curl

RUN curl -L https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz | zcat > /usr/local/bin/go-cron && chmod +x /usr/local/bin/go-cron

COPY entrypoint.sh .
COPY backup.sh .

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "entrypoint.sh"]