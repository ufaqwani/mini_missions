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
