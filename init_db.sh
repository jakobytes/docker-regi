#!/bin/bash
set -e

# Database configuration (from environment variables)
DB_NAME="${DB_NAME:-runoregi}"
DB_USER="${DB_USER:-runoregi}"
DB_PASS="${DB_PASS:-}"

# If DB_PASS is not set, generate or use a default
if [ -z "$DB_PASS" ]; then
    echo "ERROR: DB_PASS environment variable not set"
    exit 1
fi

echo "Setting up database..."

# Create database and user
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Check if database is already initialized (has tables)
TABLES=$(mysql -u root -D ${DB_NAME} -s -N -e "SHOW TABLES;" 2>/dev/null || true)

if [ -z "$TABLES" ]; then
    echo "Database is empty, importing data..."
    
    # Import data if SQL file exists
    if [ -f "/app/runoregi/database.sql" ]; then
        echo "Importing database.sql..."
        mysql -u root ${DB_NAME} < /app/runoregi/database.sql
    else
        echo "No database.sql found - database will need manual setup"
    fi
else
    echo "Database already initialized with tables"
fi

echo "Database setup complete!"
