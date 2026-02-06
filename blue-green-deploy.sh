#!/bin/bash

IMAGE_NAME="jenkins-demo"
BUILD_NUMBER=$1
PORT=3000

# Determine current environment
if docker ps --format '{{.Names}}' | grep -q "${IMAGE_NAME}-blue"; then
    CURRENT="blue"
    TARGET="green"
    TARGET_PORT=3001
elif docker ps --format '{{.Names}}' | grep -q "${IMAGE_NAME}-green"; then
    CURRENT="green"
    TARGET="blue"
    TARGET_PORT=3000
else
    # First deployment
    CURRENT="none"
    TARGET="blue"
    TARGET_PORT=3000
fi

echo "========================================="
echo "Current environment: $CURRENT"
echo "Deploying to: $TARGET"
echo "Target port: $TARGET_PORT"
echo "========================================="

# Stop and remove target if exists
docker stop ${IMAGE_NAME}-${TARGET} 2>/dev/null || true
docker rm ${IMAGE_NAME}-${TARGET} 2>/dev/null || true

# Deploy to target environment
echo "Deploying ${IMAGE_NAME}:${BUILD_NUMBER} to ${TARGET} environment..."
docker run -d --name ${IMAGE_NAME}-${TARGET} \
    -p ${TARGET_PORT}:${PORT} \
    ${IMAGE_NAME}:${BUILD_NUMBER}

# Wait for container to be healthy
echo "Waiting for container to be ready..."
sleep 10

# Run smoke tests (check if container is running and port is accessible)
echo "Running smoke tests..."
if docker ps | grep -q ${IMAGE_NAME}-${TARGET}; then
    # Test from host machine instead of inside container
    if curl -f http://localhost:${TARGET_PORT} > /dev/null 2>&1; then
        echo "✅ Smoke tests passed!"
    else
        echo "⚠️  Container running but not responding yet, giving it more time..."
        sleep 5
        if curl -f http://localhost:${TARGET_PORT} > /dev/null 2>&1; then
            echo "✅ Smoke tests passed!"
        else
            echo "❌ Smoke tests failed after retry - rolling back"
            docker stop ${IMAGE_NAME}-${TARGET}
            docker rm ${IMAGE_NAME}-${TARGET}
            echo "Rollback complete. ${CURRENT} environment still active."
            exit 1
        fi
    fi
    
    # Switch traffic (stop old environment)
    echo "Switching traffic to ${TARGET} environment..."
    
    if [ "$CURRENT" != "none" ]; then
        echo "Stopping old ${CURRENT} environment..."
        docker stop ${IMAGE_NAME}-${CURRENT}
        docker rm ${IMAGE_NAME}-${CURRENT}
    fi
    
    echo "========================================="
    echo "✅ Blue-Green deployment successful!"
    echo "Active environment: $TARGET"
    echo "Application accessible at: http://localhost:${TARGET_PORT}"
    echo "========================================="
    exit 0
else
    echo "❌ Container failed to start - rolling back"
    docker stop ${IMAGE_NAME}-${TARGET} 2>/dev/null
    docker rm ${IMAGE_NAME}-${TARGET} 2>/dev/null
    echo "Rollback complete. ${CURRENT} environment still active."
    exit 1
fi
