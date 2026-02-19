# Dockerfile for Elias-1848 (runoregi only - no MariaDB)
# Build with: docker build -t elias-1848:latest .
# Requires external MySQL database

FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=wsgi.py
ENV PYTHONPATH=/app/runoregi

# Database configuration - set these when running the container
ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_NAME=runoregi
ENV DB_USER=runoregi
ENV DB_PASS=

# Create app directory
WORKDIR /app

# Copy runoregi application
COPY runoregi/ /app/runoregi/

# Install Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages \
    flask \
    gunicorn \
    lxml \
    numpy \
    scipy \
    pymysql

# Install shortsim from git
RUN pip3 install --no-cache-dir --break-system-packages git+https://github.com/hsci-r/shortsim

# Expose port for gunicorn
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Start gunicorn
CMD ["gunicorn", "--config", "runoregi/gunicorn.conf.py", "runoregi.wsgi:application", "--bind", "0.0.0.0:8000"]
