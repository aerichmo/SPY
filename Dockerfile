FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port for Cloud Run
ENV PORT 8080
EXPOSE 8080

# Start the Flask app via Gunicorn
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8080", "--workers", "1"]
