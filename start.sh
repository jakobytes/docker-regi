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
    # Try to initialize as mysql user, fall back to current user
    if id -u mysql &>/dev/null; then
        mysql_install_db --user=mysql --datadir=/var/lib/mysql 2>/dev/null || \
            mysql_install_db --user=$CURRENT_USER --datadir=/var/lib/mysql
    else
        mysql_install_db --user=$CURRENT_USER --datadir=/var/lib/mysql
    fi
fi

# Start MariaDB - try mysql user first, then current user
if id -u mysql &>/dev/null; then
    chown mysql:mysql /tmp/mysqld 2>/dev/null || true
    mysqld_safe --datadir=/var/lib/mysql --socket=/tmp/mysqld/mysqld.sock --user=mysql &
else
    mysqld_safe --datadir=/var/lib/mysql --socket=/tmp/mysqld/mysqld.sock --user=$CURRENT_USER &
fi

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
SOCKET=/tmp/mysqld/mysqld.sock
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
