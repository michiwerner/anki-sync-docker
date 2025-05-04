FROM rust:slim-bookworm AS builder

# Add ARG for Anki version
ARG ANKI_VERSION=25.02.4

# Install protobuf and other build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    ca-certificates \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of anki-sync-server
RUN cargo install --git https://github.com/ankitects/anki.git --tag ${ANKI_VERSION} anki-sync-server

# Second stage - runtime image
FROM debian:bookworm-slim

# Create a non-root user with specific UID/GID (1000:1000)
RUN groupadd -r -g 1000 anki && useradd -r -u 1000 -g anki anki

# Copy the binary from the builder stage
COPY --from=builder /usr/local/cargo/bin/anki-sync-server /usr/local/bin/

# Create data directory
RUN mkdir -p /data && chown -R anki:anki /data

# Set working directory
WORKDIR /data

# Set environment variables
ENV SYNC_BASE=/data
ENV SYNC_HOST=0.0.0.0
ENV SYNC_PORT=27701

# Expose the sync server port
EXPOSE 27701

# Switch to non-root user
USER anki

# Command to run the container
ENTRYPOINT ["/usr/local/bin/anki-sync-server"]
