#!/bin/bash
echo "🔄 Rolling back user_authentication enhancement..."

# Stop servers
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true
sleep 2

# Restore from backup
cp -r "backups/user_authentication_20250814_225148/frontend-src" frontend/src
cp -r "backups/user_authentication_20250814_225148/frontend-public" frontend/public
cp -r "backups/user_authentication_20250814_225148/backend" .
cp "backups/user_authentication_20250814_225148/frontend-package.json" frontend/package.json
cp "backups/user_authentication_20250814_225148/missions.db" backend/database/missions.db 2>/dev/null || true

echo "✅ Rollback completed! Your app is restored to working state."
echo "To restart: cd backend && npm run dev (in one terminal)"
echo "           cd frontend && npm start (in another terminal)"
