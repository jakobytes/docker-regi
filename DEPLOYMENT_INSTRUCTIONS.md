# Elias-1848 Deployment Instructions

This document provides instructions for deploying the Elias-1848 application.

## Overview

The application is a Flask web application served with Gunicorn (port 8000) with MariaDB embedded.

## Prerequisites

- Docker installed
- Database SQL file (`database.sql`) in the `runoregi/` directory

---

## Docker

### Build the Image

```bash
docker build -t elias-1848:latest .
```

### Run Locally

```bash
docker run -p 8000:8000 elias-1848:latest
```

With custom database credentials:
```bash
docker run -p 8000:8000 \
  -e DB_USER=myuser \
  -e DB_PASS=mypass \
  elias-1848:latest
```

### Access

- Elias-1848: http://localhost:8000

---

## Database Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| DB_HOST | localhost | Database host |
| DB_PORT | 3306 | Database port |
| DB_USER | runoregi | Database user |
| DB_PASS | runoregi_password | Database password |
| DB_NAME | runoregi | Database name |
| ENABLE_LOGGING_TO_DB | false | Enable database logging |

### Database Import

The database is imported once on first start:

1. Container checks for `/var/lib/mysql/.imported` marker file
2. If not found, imports from `/app/runoregi/database.sql`
3. Creates marker file to prevent re-import on restarts

**Important**: Place your `database.sql` file in the `runoregi/` directory before building.

---

## Troubleshooting

### Check Container Logs

```bash
docker logs <container-id>
```

### Database Connection Issues

1. Verify database is running:
   ```bash
   mysqladmin ping -h localhost
   ```

2. Check credentials:
   ```bash
   mysql -u runoregi -p -e "SHOW DATABASES;"
   ```

### Restart Database Import

To re-import the database, remove the marker file:

```bash
# Inside container
rm /var/lib/mysql/.imported
# Restart container
```

---

## Security Notes

1. **Change default passwords** before production deployment
2. **Use Secrets** in Kubernetes for credentials
3. **Enable TLS** via routes/ingress for production
