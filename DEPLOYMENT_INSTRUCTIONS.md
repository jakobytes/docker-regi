# Volkslieder Deployment Instructions

This document provides instructions for deploying the Volkslieder application.

## Overview

The application is **Runoregi** (Flask/Gunicorn on port 8000), connected to an
external MySQL/MariaDB database.

## Prerequisites

- Docker installed
- External MySQL/MariaDB database with the `vldl` schema populated

---

## Docker

### Build the Image

```bash
docker build -t volkslieder:latest .
```

### Run Locally

Using the `.env` file:

```bash
# Run with env file
docker run --env-file .env -p 8000:8000 volkslieder:latest
```

### Access

- Runoregi: http://localhost:8000

---

## Database Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| DB_HOST | localhost | Database host |
| DB_PORT | 3306 | Database port |
| DB_USER | elias | Database user |
| DB_PASS | | Database password |
| DB_NAME | elias | Database name |
| DB_SSL | (unset) | Enable SSL for database connection (any non-empty value, including `false`, enables it) |
| DB_SSL_VERIFY | 1 | Set to 0 to disable SSL certificate verification |
| DB_LOGGING | (unset) | Enable logging of page requests to the `runoregi_log` table |

### SSL Configuration

For databases requiring SSL with self-signed certificates:
```bash
DB_SSL=true
DB_SSL_VERIFY=0
```

---

## Troubleshooting

### Check Container Logs

```bash
docker logs <container-id>
```

### Database Connection Issues

1. Verify database is accessible from your machine:
   ```bash
   mysql -h <DB_HOST> -u <DB_USER> -p<DB_PASS> -e "SHOW DATABASES;"
   ```

---

## Rahti (CSC OpenShift)

See [`rahti/README.md`](rahti/README.md) for full instructions.

Quick start (requires `oc` CLI and login):
```bash
rahti/deploy.sh --rebuild
```

---

## Security Notes

1. **Never commit `.env` files** - use `.env.example` as template
2. **Use Secrets** in Kubernetes/OpenShift for credentials
3. **Enable TLS** via routes/ingress for production
