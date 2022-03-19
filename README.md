# postgres-s3-backup

Yet another variation, supporting DO Spaces, hearbeats, and freshness checks.

## Usage

```yml
backuper:
  image: ghcr.io/dipdup-net/postgres-s3-backup:master
  environment:
    - S3_ENDPOINT=${S3_ENDPOINT}
    - S3_ACCESS_KEY_ID=${S3_ACCESS_KEY_ID}
    - S3_SECRET_ACCESS_KEY=${S3_SECRET_ACCESS_KEY}
    - S3_BUCKET=${S3_BUCKET}
    - S3_PATH=${S3_PATH}
    - S3_FILENAME=${S3_FILENAME}
    - POSTGRES_USER=${POSTGRES_USER:-dipdup}
    - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-changeme}
    - POSTGRES_DB=${POSTGRES_DB:-dipdup}
    - POSTGRES_HOST=${POSTGRES_HOST:-db}
    - POSTGRES_EXTRA_OPTS=${POSTGRES_EXTRA_OPTS}
    - PG_BACKUP_ACTION=${PG_BACKUP_ACTION:-dump}  # or restore
    - PG_BACKUP_FILE=${PG_BACKUP_FILE}  # for restore
    - HEARTBEAT_URI=${HEARTBEAT_URI}
    - SCHEDULE=${SCHEDULE}
```

### Digital Ocean

`S3_ENDPOINT` is your space endpoint (not space address)  
`S3_BUCKET` is space name  

### Schedule

Use CRON expression [generator](https://crontab.guru/).  
If `SCHEDULE` is empty, a one-time snapshot will be made.

### Heartbeat

`HEARTBEAT_URI` is optional