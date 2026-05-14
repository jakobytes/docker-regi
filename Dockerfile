# Dockerfile for volkslieder (runoregi + filter-visualizations - no MariaDB)
# Build with: docker build -t volkslieder:latest .
# Requires external MySQL database

FROM quay.io/hsci/shiny-verse:4.2.3

# Install Python and system dependencies for runoregi
RUN apt-get update && apt-get -y --no-install-recommends install \
    python3-pip \
    git \
    libnss-wrapper \
    gettext-base \
    libjq-dev \
    libudunits2-0 \
    libproj-dev \
    libgdal-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages needed for filter-visualizations
RUN install2.r --error \
    DT \
    jqr \
    ggplot2 \
    RCurl \
    RMariaDB \
    sf \
    stringi \
    yaml \
    shinyAce \
    shinyjs \
    shinybrowser \
    tmap \
    httr \
    tmaptools \
    xml2 \
    plotly \
    pacman \
    whisker \
    wordcloud2

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=wsgi.py
ENV PYTHONPATH=/app/runoregi

# Database configuration - set these when running the container
ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_NAME=elias
ENV DB_USER=elias
ENV DB_PASS=

# Install Python dependencies for runoregi
RUN pip3 install --no-cache-dir \
    flask \
    gunicorn \
    lxml \
    numpy \
    scipy \
    pymysql \
    git+https://github.com/hsci-r/shortsim

# Create app directory and copy runoregi application
WORKDIR /app
COPY runoregi/ /app/runoregi/

# Copy filter-visualizations application files
COPY filter-visualizations/app.R /srv/shiny-server/
COPY filter-visualizations/config.yaml /srv/shiny-server/
COPY filter-visualizations/about.html /srv/shiny-server/
COPY filter-visualizations/R/ /srv/shiny-server/R/
COPY filter-visualizations/www/ /srv/shiny-server/www/
COPY filter-visualizations/shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY filter-visualizations/passwd.template /passwd.template
COPY filter-visualizations/shiny-server.sh /usr/bin/shiny-server.sh

# Copy the startup script for both services
COPY start-both.sh /usr/bin/start-both.sh
RUN chmod a+x /usr/bin/start-both.sh && \
    mkdir -p /var/log/shiny-server && \
    chmod a+rwx /var/log/shiny-server && \
    chmod a+rwx /srv/shiny-server && \
    chmod a+rwx /usr/local/lib/R/site-library

# Expose ports for gunicorn and shiny server
EXPOSE 8000
EXPOSE 3838

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Default command runs both services
CMD ["/usr/bin/start-both.sh"]