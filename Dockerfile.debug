# Debug container for testing database connectivity
# Build with: docker build -t db-debug:latest -f Dockerfile.debug .
# Run locally: docker run -it db-debug /bin/sh

FROM debian:bookworm-slim

# Install debugging tools including MariaDB client
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-client \
    iputils-ping \
    net-tools \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Default command
CMD ["/bin/sh"]
