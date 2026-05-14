#!/bin/bash

# Start shiny server in background
echo "Starting Shiny server on port 3838..."
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

# pass the environment variables for DB access to the R session
env | grep DB_ > /srv/shiny-server/.Renviron 2>/dev/null || true
env | grep ENABLE_LOGGING_TO_DB >> /srv/shiny-server/.Renviron 2>/dev/null || true
chown shiny /srv/shiny-server/.Renviron 2>/dev/null || true

# Start shiny server in background
shiny-server 2>&1 &
SHINY_PID=$!
echo "Shiny server started with PID $SHINY_PID"

# Wait for shiny server to be ready
sleep 3

# Start gunicorn for runoregi in background
echo "Starting gunicorn on port 8000..."
cd /app
PYTHONPATH=/app/runoregi gunicorn --config runoregi/gunicorn.conf.py runoregi.wsgi:application --bind 0.0.0.0:8000 &
GUNICORN_PID=$!
echo "Gunicorn started with PID $GUNICORN_PID"

# Keep container running as long as either process is alive
while kill -0 $SHINY_PID 2>/dev/null || kill -0 $GUNICORN_PID 2>/dev/null; do
    sleep 1
done

echo "One of the services exited, stopping..."
kill $SHINY_PID 2>/dev/null || true
kill $GUNICORN_PID 2>/dev/null || true