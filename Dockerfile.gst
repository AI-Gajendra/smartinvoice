# ============================================================================
# Smart iInvoice - GST Verification Service Dockerfile
# ============================================================================

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy GST service requirements and install
COPY "gst verification template/requirements.txt" .
RUN pip install --no-cache-dir -r requirements.txt

# Copy GST service code
COPY "gst verification template/" .

# Create non-root user
RUN groupadd -r gstservice && useradd -r -g gstservice gstservice
USER gstservice

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5001/ || exit 1

# Run the GST service
CMD ["python", "app.py"]
