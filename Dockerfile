FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_SECRET_KEY=change-me \
    AUTH_DB_PATH=/data/users.db \
    APP_PORT=5050

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Install browser dependencies so JS rendering works when enabled
RUN playwright install-deps chromium && playwright install chromium

COPY . .

RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 5050

CMD ["python", "main.py"]
