# Dockerfile for Elias-1848 + MariaDB
# Build with: docker build -t elias-1848:latest .
# Secrets: Set DB_PASS environment variable when running the container

FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-transport-https \
    mariadb-server \
    mariadb-client \
    default-libmysqlclient-dev \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    git \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    libopenblas-dev \
    liblapack-dev \
    gfortran \
    sudo \
    xtail \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=wsgi.py
ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_NAME=runoregi
ENV DB_USER=runoregi
ENV DB_PASS=
ENV DB_SOCKET=/tmp/mysqld/mysqld.sock

# Create app directory
WORKDIR /app

# Copy runoregi application
COPY runoregi/ /app/runoregi/

# Install Python dependencies from requirements.txt
RUN pip3 install --no-cache-dir --break-system-packages \
    flask \
    gunicorn \
    lxml \
    numpy \
    scipy \
    pymysql

# Install shortsim from git
RUN pip3 install --no-cache-dir --break-system-packages git+https://github.com/hsci-r/shortsim

# Copy database initialization script
COPY init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose port for gunicorn
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Start script
CMD ["/usr/local/bin/start.sh"]
