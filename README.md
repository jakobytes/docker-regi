# Volkslieder

Docker deployment for the Volkslieder application, combining:
- **runoregi** - Flask/Gunicorn web application (port 8000)
- **filter-visualizations** - Shiny Server application (port 3838)

## Quick Start

```bash
# Build the image
docker build -t volkslieder:latest .

# Create .env with database credentials (see DEPLOYMENT_INSTRUCTIONS.md)
# Run
docker run -d --name volkslieder -p 8000:8000 -p 3838:3838 --env-file .env volkslieder:latest
```

Access:
- http://localhost:8000 - runoregi
- http://localhost:3838 - filter-visualizations