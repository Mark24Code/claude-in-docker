# build and push
docker buildx build --platform linux/amd64,linux/arm64 -t mark24code/claude-in-docker:latest -t mark24code/claude-in-docker:v0.1.0  --push .