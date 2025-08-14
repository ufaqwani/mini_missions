#!/bin/bash
echo "🧪 Testing production build locally..."
echo "Building frontend..."
cd frontend && npm run build && cd ..
echo "Starting production server..."
NODE_ENV=production npm start
