# Anki Sync Server Docker

A Docker container for running a self-hosted Anki sync server.

## Quick Start with GitHub Container Registry

```
docker run -d \
  --name anki-sync-server \
  -p 27701:27701 \
  -e SYNC_USER1=username:password \
  -v anki-data:/data \
  ghcr.io/michiwerner/anki-sync-docker:latest
```

## Platform Support

This image supports multiple architectures:
- `linux/amd64` - For Intel/AMD processors
- `linux/arm64` - For ARM64 processors (Apple Silicon, Raspberry Pi 4/5, AWS Graviton, etc.)

Docker will automatically pull the correct image for your platform.

## Build Locally

```
docker build -t anki-sync-server .
```

To build with a specific Anki version:

```
docker build -t anki-sync-server --build-arg ANKI_VERSION=25.02.5 .
```

## Run

```
docker run -d \
  --name anki-sync-server \
  -p 27701:27701 \
  -e SYNC_USER1=username:password \
  -v anki-data:/data \
  anki-sync-server
```

The server will always be running and ready to accept connections from Anki clients.

## Docker Compose

```
docker-compose up -d
```

Make sure to edit the `docker-compose.yml` file to set your username and password.

You can specify a different Anki version in the `docker-compose.yml` file by changing the `ANKI_VERSION` build arg.

## CI/CD Pipeline

This repository includes a GitHub Actions workflow that automates the building and pushing of the Docker image to the GitHub Container Registry (GHCR). The workflow handles different scenarios:

1.  **Push to `main` branch:**
    *   Builds the Docker image using the `LATEST_ANKI_VERSION` (defined in the workflow file) for both `linux/amd64` and `linux/arm64` platforms.
    *   Pushes the multi-architecture image and tags it solely as `latest`.

2.  **Push to a version tag (e.g., `vX.Y.Z`):**
    *   Extracts the version `X.Y.Z` from the tag.
    *   Builds the Docker image using this specific Anki version for both `linux/amd64` and `linux/arm64` platforms.
    *   Pushes the multi-architecture image and tags it with the version (e.g., `X.Y.Z`).
    *   If the version `X.Y.Z` from the tag matches the `LATEST_ANKI_VERSION`, the `latest` tag is also updated to point to this build.

3.  **Pull Request to `main` branch (and other cases):**
    *   Builds the Docker image using the `LATEST_ANKI_VERSION` for the `linux/amd64` platform only.
    *   The image is **not** pushed to the registry. This step is for validation and testing.

The workflow is defined in `.github/workflows/docker-build.yml`. It leverages multi-platform builds and caching for efficiency.

### Image Tags

The following primary tags are automatically generated and pushed to GHCR based on the CI/CD pipeline:

-   `latest`:
    *   Updated on every push to the `main` branch (points to the image built with `LATEST_ANKI_VERSION`).
    *   Also updated when a version tag (e.g., `vX.Y.Z`) is pushed, if that version `X.Y.Z` matches the `LATEST_ANKI_VERSION`.
-   `X.Y.Z`:
    *   Created when a git tag like `vX.Y.Z` is pushed. The image is built with Anki version `X.Y.Z` and tagged as `X.Y.Z` (the 'v' prefix is removed).

For pull request builds, temporary tags (e.g., `build-<PR_NUMBER>-<SHA>`) might be generated for caching and identification purposes but are not pushed to the public registry.

## Configuration

### Environment Variables

- `SYNC_USER1`: Required. Format is `username:password` for the first user
- `SYNC_USER2`, `SYNC_USER3`, etc.: Optional additional users
- `SYNC_HOST`: Host to bind to (default: 0.0.0.0)
- `SYNC_PORT`: Port to bind to (default: 27701)
- `SYNC_BASE`: Data storage location (default: /data)
- `PASSWORDS_HASHED`: Set to 1 if providing hashed passwords
- `MAX_SYNC_PAYLOAD_MEGS`: Maximum payload size in megabytes


### Build Arguments

- `ANKI_VERSION`: The Anki version to build the sync server from (default: 25.02.5)

### Volumes

- `/data`: Stores all sync data

### User Permissions

The container runs as a non-root user with UID/GID 1000:1000. If you're mounting a volume from your host, make sure it has appropriate permissions.

## Client Setup

In Anki desktop, go to Preferences → Network and set the custom sync server URL to:

```
http://your-server-ip:27701/
```

For AnkiMobile, ensure "Allow Anki to access local network" is enabled in iOS settings.

## Security Considerations

This server uses unencrypted HTTP. For public access, consider using:
- A VPN
- HTTPS reverse proxy
- Container networking isolation

## Disclaimer

This project is not affiliated with or endorsed by Anki or Ankitects. "Anki" is a trademark of Ankitects Pty Ltd.

This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software. See the AGPL-3.0 license for more details.

## License

This Docker image packages Anki sync server which is licensed under AGPL-3.0.
