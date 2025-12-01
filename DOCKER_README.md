# Smart iInvoice - Docker Deployment Guide

## Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- Gemini API Key (from Google AI Studio)

### 1. Clone and Configure

```bash
# Clone the repository
git clone <repository-url>
cd smartinvoice

# Create environment file
cp .env.example .env

# Edit .env and add your GEMINI_API_KEY
```

### 2. Production Deployment

```bash
# Build and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 3. Development Mode

```bash
# Start with hot-reload enabled
docker-compose -f docker-compose.dev.yml up --build

# This enables:
# - Django debug mode
# - Code hot-reload
# - Mock GST service (faster)
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| web | 8000 | Django application |
| gst-service | 5001 | GST verification API |
| redis | 6379 | Message broker |
| celery | - | Background worker |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | Yes | Google Gemini API key |
| `SECRET_KEY` | Yes (prod) | Django secret key |
| `ALLOWED_HOSTS` | No | Comma-separated hosts |
| `DEBUG` | No | Enable debug mode |

## Useful Commands

```bash
# Create superuser
docker-compose exec web python manage.py createsuperuser

# Run migrations
docker-compose exec web python manage.py migrate

# Run tests
docker-compose exec web python manage.py test

# View logs
docker-compose logs -f web
docker-compose logs -f celery

# Shell access
docker-compose exec web bash

# Rebuild single service
docker-compose up -d --build web
```

## Volumes

- `./db.sqlite3` - SQLite database
- `./media` - Uploaded files
- `./logs` - Application logs
- `static_files` - Collected static files

## Health Checks

All services include health checks:
- Web: `http://localhost:8000/`
- GST: `http://localhost:5001/`
- Redis: `redis-cli ping`

## Troubleshooting

### Container won't start
```bash
docker-compose logs <service-name>
```

### Database issues
```bash
docker-compose exec web python manage.py migrate --run-syncdb
```

### Permission issues
```bash
sudo chown -R $USER:$USER ./media ./logs
```
