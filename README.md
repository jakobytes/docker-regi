# Volkslieder

Docker deployment for the Volkslieder instance of
**runoregi** - Flask/Gunicorn web application (port 8000).

## Quick Start

```bash
# Build the image
docker build -t volkslieder:latest .

# Create .env with database credentials (see DEPLOYMENT_INSTRUCTIONS.md)
# Run
docker run -d --name volkslieder -p 8000:8000 --env-file .env volkslieder:latest
```

Access: http://localhost:8000
