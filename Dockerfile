# Stage 1: Builder
FROM python:3.10-slim as builder

# Set environment variables to prevent Python from writing .pyc files and to buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container to /app
WORKDIR /app

# Install system dependencies required for building Python packages AND Node.js
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc build-essential git curl && \
    # Install Node.js 18.x (required for chainlit)
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    # Install pnpm globally
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt first to leverage Docker cache
COPY requirements.txt .

# Create a virtual environment
RUN python -m venv /opt/venv

# Activate the virtual environment and update PATH
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Install your chainlit fork (this will override any chainlit version from requirements.txt)
RUN pip install git+https://github.com/guyvandam/chainlit.git#subdirectory=backend/

# Stage 2: Final runtime image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

# Set the working directory in the container to /app
WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy the application code into the container
COPY . /app

# Command to run the Chainlit server using shell form for environment variable expansion
CMD python -m chainlit run src/app.py -h --host 0.0.0.0 --port ${PORT}