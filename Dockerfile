# ============================================================================
# Smart iInvoice - Dockerfile for Render Deployment
# ============================================================================

FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    ALLOWED_HOSTS="localhost,127.0.0.1,smartinvoice-p2hv.onrender.com,.onrender.com"

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libpq-dev \
    gcc \
    libc-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# Builder stage - Install Python dependencies
# ============================================================================
FROM base AS builder

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --user -r requirements.txt && \
    pip install --user gunicorn flask requests bs4 uvicorn asgiref

# ============================================================================
# Production stage
# ============================================================================
FROM base AS production

# Create non-root user for security
RUN groupadd -r smartinvoice && useradd -r -g smartinvoice smartinvoice

# Copy installed packages from builder
COPY --from=builder /root/.local /home/smartinvoice/.local
ENV PATH=/home/smartinvoice/.local/bin:$PATH

# Copy application code
COPY --chown=smartinvoice:smartinvoice . .

# Create necessary directories
RUN mkdir -p /app/logs /app/media /app/staticfiles /app/data && \
    chown -R smartinvoice:smartinvoice /app

# Switch to non-root user
USER smartinvoice

# Collect static files
RUN python manage.py collectstatic --noinput --clear 2>/dev/null || true

# Expose ports
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Default command - run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "4", "smartinvoice.wsgi:application"]
