# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory in container
WORKDIR /app

# Install system dependencies including Tesseract OCR
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    tesseract-ocr \
    tesseract-ocr-eng \
    libtesseract-dev \
    libleptonica-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download SentenceTransformer model during build (prevents runtime download)
# This caches the ~80MB model in the Docker image for faster cold starts
RUN python -c "from sentence_transformers import SentenceTransformer; print('📥 Downloading SentenceTransformer model...'); model = SentenceTransformer('all-MiniLM-L6-v2'); print('✅ Model downloaded and cached')"

# Copy the rest of the application code
COPY . .

# Create and set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

# Expose port 8080
EXPOSE 8080

# Command to run the application
# Use PORT environment variable for Cloud Run compatibility (defaults to 8080)
CMD ["python", "main.py"]
