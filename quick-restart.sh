#!/bin/bash
echo "🔄 Quick restart for overdue features..."
pkill -f "npm run dev" 2>/dev/null || true
sleep 1
cd backend && npm run dev &
echo "✅ Backend restarted with overdue detection!"
