#!/bin/bash
set -e

echo "Starting MariaDB..."

# Create run directory for MariaDB in a writable location
mkdir -p /tmp/mysqld

# Get current user (for OpenShift non-root)
CURRENT_USER=$(whoami)
echo "Running as user: $CURRENT_USER"

# Initialize MariaDB data directory if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    # Initialize without --user flag (running as non-root)
    mysql_install_db --datadir=/var/lib/mysql
fi

# Start MariaDB directly (not mysqld_safe)
# With PVC mounted to /var/lib/mysql, this should work as non-root
SOCKET=/tmp/mysqld/mysqld.sock
DATADIR=/var/lib/mysql

# Create run directory
mkdir -p /tmp/mysqld

# Run mysqld as current user (no --user flag for non-root)
mysqld \
    --datadir=$DATADIR \
    --socket=$SOCKET \
    --bind-address=127.0.0.1 \
    &

MARIADB_PID=$!
echo "MariaDB started with PID $MARIADB_PID"

echo "MariaDB starting..."

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
for i in {1..600}; do
    # Check if socket file exists
    if [ -S "$SOCKET" ]; then
        if mysqladmin ping --socket=$SOCKET --silent 2>/dev/null; then
            echo "MariaDB is up!"
            break
        fi
    fi
    echo "Waiting... ($((i/60)) min $((i%60)) sec)"
    sleep 1
done

# Initialize database
echo "Initializing database..."
/usr/local/bin/init_db.sh

# Change to app directory
cd /app/runoregi

# Start gunicorn
echo "Starting gunicorn..."
exec gunicorn --config gunicorn.conf.py wsgi:application --bind 0.0.0.0:8000
