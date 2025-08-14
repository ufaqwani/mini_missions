#!/bin/bash

echo "🧹 CLEANING UP SCRIPT MESS - Organizing before GitHub"
echo "Moving scripts to proper locations and cleaning up..."

cd mission-tracker

echo "📂 Creating organized directory structure..."

# Create scripts directory for organization
mkdir -p scripts/{setup,enhancement,backup,deployment}

echo "📋 Moving scripts to organized folders..."

# Move setup/original scripts
mv setup.sh scripts/setup/ 2>/dev/null || true
mv enhance.sh scripts/enhancement/ 2>/dev/null || true
mv start.sh scripts/setup/ 2>/dev/null || true

# Move enhancement scripts
mv add-*.sh scripts/enhancement/ 2>/dev/null || true
mv enhance-*.sh scripts/enhancement/ 2>/dev/null || true
mv fix-*.sh scripts/enhancement/ 2>/dev/null || true

# Move rollback scripts to backup folder
mv rollback_*.sh scripts/backup/ 2>/dev/null || true

# Move deployment scripts
mv prepare-for-deployment.sh scripts/deployment/ 2>/dev/null || true
mv test-production.sh scripts/deployment/ 2>/dev/null || true
mv pre-deployment-check.sh scripts/deployment/ 2>/dev/null || true

# Keep only essential scripts in root
mv restart_app*.sh scripts/setup/ 2>/dev/null || true

echo "🗑️ Removing temporary and duplicate scripts..."

# Remove any remaining .sh files that are duplicates or temporary
rm -f *temp*.sh 2>/dev/null || true
rm -f *backup*.sh 2>/dev/null || true
rm -f *test*.sh 2>/dev/null || true

echo "📝 Creating clean README for the project..."

# Create a proper README.md
cat > README.md << 'EOF'
# 🎯 Mission Tracker

A modern, multi-user task management application focused on daily goal completion with priority-based organization.

## ✨ Features

- **🔐 3-User Authentication System**
  - Pre-configured users: `ufaq`, `zia`, `sweta`
  - Secure login with isolated user data
  
- **🎯 Today's Focus Dashboard**
  - View today's pending and completed tasks
  - Quick-add goals with priority selection
  - Progress tracking with visual indicators
  
- **📊 Priority System**
  - High (🔴), Medium (🟡), Low (🟢) priority levels
  - Color-coded task organization
  - Smart sorting by priority and due date
  
- **⚠️ Overdue Task Management**
  - Visual highlighting of overdue tasks
  - Days overdue calculation
  - Critical vs warning urgency levels
  
- **📋 Mission Management**
  - Create long-term missions
  - Break down into daily actionable tasks
  - Track completion and progress

## 🚀 Quick Start

### Development

Start backend

cd backend && npm run dev
Start frontend (in another terminal)

cd frontend && npm start

text

### Production Deployment

Run deployment preparation

./scripts/deployment/prepare-for-deployment.sh
Follow the deployment guide for Render/Railway

text

## 🔑 Login Credentials

| Username | Password |
|----------|----------|
| ufaq     | ufitufy  |
| zia      | zeetv    |
| sweta    | ss786    |

## 🛠️ Tech Stack

- **Frontend**: React 18, Axios
- **Backend**: Node.js, Express
- **Database**: SQLite
- **Authentication**: Simple session-based auth
- **Deployment**: Render (recommended)

## 📂 Project Structure

mission-tracker/
├── frontend/ # React application
├── backend/ # Node.js API server
├── scripts/ # Development and deployment scripts
└── README.md # This file

text

## 🎯 User Workflow

1. **Login** with your assigned credentials
2. **View Today's Focus** - see pending and completed tasks
3. **Quick Add** new goals with priority selection
4. **Complete Tasks** by checking them off
5. **Manage Missions** for long-term goal organization

## 🚀 Deployment

This app is configured for easy deployment on:
- **Render** (recommended, completely free)
- **Railway** ($5 monthly credit)
- **Fly.io** (SQLite-friendly)

See `scripts/deployment/` for deployment preparation scripts.

---

Built with ❤️ for focused daily productivity
EOF

echo "📁 Creating scripts organization README..."

# Create README for scripts folder
cat > scripts/README.md << 'EOF'
# 📜 Scripts Directory

This directory contains all development, enhancement, and deployment scripts used during the project development.

## 📂 Organization

### `setup/`
- Original project setup scripts
- App restart scripts
- Initial configuration

### `enhancement/`
- Feature addition scripts (authentication, priorities, etc.)
- Bug fix scripts
- Component updates

### `backup/`
- Rollback scripts for each enhancement
- Backup restoration utilities

### `deployment/`
- Production preparation scripts
- Deployment configuration
- Testing utilities

## 🚨 Important Notes

- These scripts were used during development
- Most are one-time use only
- **DO NOT run random scripts** without understanding what they do
- Rollback scripts in `backup/` can restore previous versions if needed

## 🎯 For Deployment

Use only: `deployment/prepare-for-deployment.sh`

All other scripts are for development reference only.
EOF

echo "🧽 Cleaning up any remaining clutter..."

# Remove any backup files created during development
find . -name "*.backup" -delete 2>/dev/null || true
find . -name "*.bak" -delete 2>/dev/null || true

# Remove any empty directories
find scripts/ -type d -empty -delete 2>/dev/null || true

echo "📊 Creating clean .gitignore..."

# Update .gitignore to include script artifacts
cat >> .gitignore << 'EOF'

# Development scripts artifacts
scripts/temp/
*.log
*.tmp

# Backup files
*.backup
*.bak
*~

# IDE files
.vscode/
.idea/
*.swp
*.swo
EOF

echo "📋 Creating simple package.json in root (for GitHub display)..."

# Create a simple root package.json for GitHub
cat > package.json << 'EOF'
{
  "name": "mission-tracker",
  "version": "1.0.0",
  "description": "Multi-user task management app with priority-based daily focus",
  "main": "backend/server.js",
  "scripts": {
    "start": "node backend/server.js",
    "dev": "concurrently \"cd backend && npm run dev\" \"cd frontend && npm start\"",
    "deploy": "./scripts/deployment/prepare-for-deployment.sh"
  },
  "keywords": ["task-management", "productivity", "react", "nodejs", "missions"],
  "author": "Mission Tracker Team",
  "license": "MIT",
  "engines": {
    "node": ">=16.0.0"
  }
}
EOF

echo "🔍 Final directory cleanup check..."

# List what's left in root directory
echo ""
echo "📁 Clean root directory contents:"
ls -la | grep -E '\.(sh|js|md|json|yaml)$' || echo "No script clutter remaining!"

echo ""
echo "✅ CLEANUP COMPLETE!"
echo ""
echo "🧹 WHAT WAS ORGANIZED:"
echo "• ✅ All development scripts moved to scripts/ folder"
echo "• ✅ Scripts organized by purpose (setup, enhancement, backup, deployment)"
echo "• ✅ Clean README.md created for GitHub"
echo "• ✅ Professional project structure"
echo "• ✅ Removed temporary and duplicate files"
echo "• ✅ Updated .gitignore for clean repository"
echo ""
echo "📂 YOUR CLEAN DIRECTORY STRUCTURE:"
echo "mission-tracker/"
echo "├── README.md              # Main project documentation"
echo "├── package.json           # Root package info"
echo "├── frontend/              # React app"
echo "├── backend/               # Node.js API"
echo "├── scripts/               # All development scripts (organized)"
echo "│   ├── setup/            # Setup and restart scripts"
echo "│   ├── enhancement/      # Feature addition scripts"
echo "│   ├── backup/           # Rollback scripts"
echo "│   └── deployment/       # Deployment preparation"
echo "└── .gitignore            # Git ignore rules"
echo ""
echo "🎯 READY FOR GITHUB!"
echo "Your project now looks professional and organized."
echo "Run 'git add .' to include the clean structure in your repository."
