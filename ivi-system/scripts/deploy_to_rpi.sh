#!/bin/bash
TARGET_IP="192.168.0.10"
USER="root"

echo "Deploying to $TARGET_IP..."

scp -r build/can-service/can_service $USER@$TARGET_IP:/usr/bin/
scp -r build/pdc-service/pdc_service $USER@$TARGET_IP:/usr/bin/
scp -r build/media-service/media_service $USER@$TARGET_IP:/usr/bin/
scp -r build/cluster-ui/appcluster-ui $USER@$TARGET_IP:/usr/bin/
scp ipc/vsomeip-config/vsomeip.json $USER@$TARGET_IP:/etc/vsomeip/

echo "Done. Restart services on target."
