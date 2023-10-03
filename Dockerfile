FROM alpine:3.15

RUN apk update \
    && apk --no-cache add dumb-init postgresql-client curl python3

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-396.0.0-linux-x86_64.tar.gz

# ARM
# RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-396.0.0-linux-arm.tar.gz

RUN tar -xf google-cloud-cli-396.0.0-linux-x86_64.tar.gz

RUN ./google-cloud-sdk/install.sh --usage-reporting false -q

RUN rm google-cloud-cli-396.0.0-linux-x86_64.tar.gz

ENV PATH $PATH:/google-cloud-sdk/bin/

ADD boto.config /root/.boto

RUN curl -L https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz | zcat > /usr/local/bin/go-cron && chmod +x /usr/local/bin/go-cron

COPY entrypoint.sh .
COPY backup.sh .

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "entrypoint.sh"]