#!/bin/bash

IMAGE_NAME="jenkins-demo"
BUILD_NUMBER=$1
PORT=3000

# Determine current environment
if docker ps --format '{{.Names}}' | grep -q "${IMAGE_NAME}-blue"; then
    CURRENT="blue"
    TARGET="green"
elif docker ps --format '{{.Names}}' | grep -q "${IMAGE_NAME}-green"; then
    CURRENT="green"
    TARGET="blue"
else
    # First deployment
    CURRENT="none"
    TARGET="blue"
fi

echo "========================================="
echo "Current environment: $CURRENT"
echo "Deploying to: $TARGET"
echo "========================================="

# Stop and remove target if exists
docker stop ${IMAGE_NAME}-${TARGET} 2>/dev/null || true
docker rm ${IMAGE_NAME}-${TARGET} 2>/dev/null || true

# Deploy to target environment
echo "Deploying ${IMAGE_NAME}:${BUILD_NUMBER} to ${TARGET} environment..."
docker run -d --name ${IMAGE_NAME}-${TARGET} \
    -p $((PORT + (TARGET == "green" ? 1 : 0))):${PORT} \
    ${IMAGE_NAME}:${BUILD_NUMBER}

# Wait for container to be healthy
echo "Waiting for container to be ready..."
sleep 5

# Run smoke tests
echo "Running smoke tests..."
if docker exec ${IMAGE_NAME}-${TARGET} curl -f http://localhost:${PORT} > /dev/null 2>&1; then
    echo "✅ Smoke tests passed!"
    
    # Switch traffic (in real production, you'd update load balancer here)
    echo "Switching traffic to ${TARGET} environment..."
    
    # Stop old environment
    if [ "$CURRENT" != "none" ]; then
        echo "Stopping old ${CURRENT} environment..."
        docker stop ${IMAGE_NAME}-${CURRENT}
        docker rm ${IMAGE_NAME}-${CURRENT}
    fi
    
    echo "========================================="
    echo "✅ Blue-Green deployment successful!"
    echo "Active environment: $TARGET"
    echo "========================================="
    exit 0
else
    echo "❌ Smoke tests failed - rolling back"
    docker stop ${IMAGE_NAME}-${TARGET}
    docker rm ${IMAGE_NAME}-${TARGET}
    echo "Rollback complete. ${CURRENT} environment still active."
    exit 1
fi
