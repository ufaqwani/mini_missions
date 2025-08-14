#!/bin/bash
echo "🔄 Rolling back simple_auth enhancement..."

# Stop servers
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true
sleep 2

# Restore from backup
rm -rf "./frontend/src"
rm -rf "./frontend/public"
rm -rf "./backend"
rm -f "./frontend/package.json"

cp -r "backups/simple_auth_20250814_231733/frontend-src" "./frontend/src"
cp -r "backups/simple_auth_20250814_231733/frontend-public" "./frontend/public"
cp -r "backups/simple_auth_20250814_231733/backend" "./"
cp "backups/simple_auth_20250814_231733/frontend-package.json" "./frontend/package.json"
cp "backups/simple_auth_20250814_231733/missions.db" "./backend/database/missions.db" 2>/dev/null || true

echo "✅ Rollback completed! Your app is restored to working state."
echo "To restart: cd ./backend && npm run dev"
echo "           cd ./frontend && npm start"
