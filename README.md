# 🎯 Mission Tracker

A modern, multi-user task management application focused on daily goal completion with priority-based organization.

## ✨ Features

- **🔐 3-User Authentication System**
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
