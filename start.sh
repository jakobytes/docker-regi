#!/bin/bash
set -e

echo "Starting MariaDB..."

# Create run directory for MariaDB
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize MariaDB data directory if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in background
mysqld_safe --datadir=/var/lib/mysql --user=mysql &

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
for i in {1..60}; do
    if mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo "MariaDB is up!"
        break
    fi
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
