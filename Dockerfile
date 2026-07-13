FROM rust:1.89-slim-bookworm AS builder

# Add ARG for Anki version
ARG ANKI_VERSION=26.05

# Install protobuf and other build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    ca-certificates \
    git \
    patch \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy patches
COPY patches /patches

# Install specific version of anki-sync-server
RUN git clone --recursive --depth 1 --branch ${ANKI_VERSION} https://github.com/ankitects/anki.git /usr/src/anki \
    && cd /usr/src/anki \
    && if [ -d /patches/${ANKI_VERSION} ]; then \
         for p in /patches/${ANKI_VERSION}/*.patch; do \
           git apply "$p"; \
         done; \
       fi \
    && PROTOC=/usr/bin/protoc cargo install --path rslib/sync --root /usr/local

# Second stage - runtime image
FROM debian:bookworm-slim

# Create a non-root user with specific UID/GID (577:577)
RUN groupadd -r -g 577 ankisync && useradd -r -u 577 -g ankisync ankisync

# Copy the binary from the builder stage
COPY --from=builder /usr/local/bin/anki-sync-server /usr/local/bin/

# Create data directory
RUN mkdir -p /data && chown -R ankisync:ankisync /data

# Set working directory
WORKDIR /data

# Set environment variables
ENV SYNC_BASE=/data
ENV SYNC_HOST=0.0.0.0
ENV SYNC_PORT=27701

# Expose the sync server port
EXPOSE 27701

# Switch to non-root user
USER ankisync

# Command to run the container
ENTRYPOINT ["/usr/local/bin/anki-sync-server"]
