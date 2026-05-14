# Volkslieder Deployment - Checkpoint

## Local Development Status
- ✅ Docker image builds successfully with both apps (no MariaDB)
- ✅ runoregi app working on port 8000 with database connection
- ✅ filter-visualizations Shiny app working on port 3838

## What Works (Local)
1. **Docker Image**: Successfully builds `volkslieder:test` with both runoregi and filter-visualizations
2. **runoregi**: Gunicorn serves data from vldl database on port 8000
3. **filter-visualizations**: Shiny server running on port 3838
4. **Database**: Connected to vldl database with SSL support

## Files Changed
- `Dockerfile` - Combined Python/R Docker image for both apps
- `start-both.sh` - Startup script for gunicorn + shiny-server
- `filter-visualizations/R/data.R` - Fixed RMariaDB connection (username vs user param)

## Usage
```bash
# Build the image
docker build -t volkslieder:test .

# Create .env with database credentials
# (see DEPLOYMENT_INSTRUCTIONS.md for required variables)

# Run
docker run -d --name volkslieder -p 8000:8000 -p 3838:3838 --env-file .env volkslieder:test
```
