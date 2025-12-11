# Use Python 3.11.14 as base
FROM python:3.11.14-slim

# Set working directory
WORKDIR /dbt

# Install system dependencies for Postgres and dbt
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy your dbt project into the container
COPY . /dbt/
COPY requirements.txt /dbt/

# Install Python dependencies and dbt packages
RUN pip install --upgrade pip && \
    pip install -r /dbt/requirements.txt && \
    dbt deps --project-dir /dbt

# Set default working directory
WORKDIR /dbt
