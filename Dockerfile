# Dockerfile for volkslieder (runoregi only - no MariaDB)
# Build with: docker build -t volkslieder:latest .
# Requires external MySQL database

FROM python:3.11-slim

RUN apt-get update && apt-get -y --no-install-recommends install \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/runoregi
# OpenShift runs as a random UID without a home directory; gunicorn needs a
# writable $HOME for its control socket.
ENV HOME=/tmp

WORKDIR /app
COPY runoregi/requirements.txt /app/runoregi/requirements.txt
RUN pip install --no-cache-dir -r /app/runoregi/requirements.txt

COPY runoregi/ /app/runoregi/

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["gunicorn", "--config", "runoregi/gunicorn.conf.py", "runoregi.wsgi:application", "--bind", "0.0.0.0:8000"]
