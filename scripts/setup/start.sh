#!/bin/bash
echo "Starting Mission Tracker..."
echo "Starting backend server..."
cd backend
npm run dev &
BACKEND_PID=$!

echo "Starting frontend..."
cd ../frontend
npm start &
FRONTEND_PID=$!

echo "Both servers are starting..."
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "To stop both servers, press Ctrl+C"

# Wait for user to press Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
