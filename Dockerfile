FROM python:3.11

# Update packagtes, install necessary tools into the base image, clean up and clone git repository
RUN apt update \
    && apt install -y --no-install-recommends --no-install-suggests git apache2 \
    && apt autoremove -y --purge \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Change working directory to cloned git repository
WORKDIR ollama_proxy_server

# Copy files into working directory (including config.ini and authorized_users.txt)
COPY . .

# Install all needed requirements
RUN pip3 install -e .

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /ollama_proxy_server
USER appuser

# Set Python path to include current directory
ENV PYTHONPATH="/app:$PYTHONPATH"
# Do not buffer output, e.g. logs to stdout
ENV PYTHONUNBUFFERED=1

# Set command line parameters
CMD ["python3", "-m", "ollama_proxy_server.main", "--config", "./config.ini", "--users_list", "./authorized_users.txt", "--port", "8080"]
