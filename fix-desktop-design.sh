#!/bin/bash

echo "🖥️ FIXING DESKTOP-FIRST DESIGN - PROPER DESKTOP EXPERIENCE"
echo "Creating beautiful desktop interface with option to disable mobile entirely..."

cd mission-tracker

echo "📦 Creating backup..."
cp -r frontend/src frontend/src.backup-desktop-fix

echo "🎨 Option 1: Pure Desktop-Only Design (Recommended)"
echo "🎨 Option 2: Proper Desktop-First with Mobile Support"
echo ""
read -p "Choose option (1 for Desktop-Only, 2 for Desktop-First Responsive): " choice

if [ "$choice" = "1" ]; then
    echo "🖥️ Creating DESKTOP-ONLY design with no mobile support..."
    
    # Pure desktop-only CSS
    cat > frontend/src/index.css << 'EOF'
/* DESKTOP-ONLY DESIGN - NO MOBILE SUPPORT */
/* Beautiful Professional Desktop Interface */

:root {
  /* Professional Color System */
  --primary: #2563eb;
  --primary-dark: #1d4ed8;
  --primary-light: #3b82f6;
  --primary-bg: #eff6ff;
  
  --success: #059669;
  --success-light: #10b981;
  --success-bg: #ecfdf5;
  
  --warning: #d97706;
  --warning-light: #f59e0b;
  --warning-bg: #fffbeb;
  
  --danger: #dc2626;
  --danger-light: #ef4444;
  --danger-bg: #fef2f2;
  
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-200: #e5e7eb;
  --gray-300: #d1d5db;
  --gray-500: #6b7280;
  --gray-600: #4b5563;
  --gray-700: #374151;
  --gray-800: #1f2937;
  --gray-900: #111827;
  
  /* Desktop Spacing */
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.25rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-10: 2.5rem;
  --space-12: 3rem;
  --space-16: 4rem;
  
  /* Professional Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  
  /* Desktop Border Radius */
  --radius: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
  --radius-2xl: 1.5rem;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  color: var(--gray-800);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  background-attachment: fixed;
  font-size: 14px;
}

/* Desktop App Container */
.app {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  background-attachment: fixed;
}

/* Professional Desktop Header */
.header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  padding: var(--space-6) var(--space-8);
  position: sticky;
  top: 0;
  z-index: 50;
  box-shadow: var(--shadow-sm);
}

.header-content {
  max-width: 1600px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.logo h1 {
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.user-menu {
  display: flex;
  align-items: center;
  gap: var(--space-6);
}

.user-info {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-3) var(--space-5);
  background: var(--gray-50);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 1rem;
  box-shadow: var(--shadow);
}

/* Desktop Main Container */
.main-container {
  max-width: 1600px;
  margin: 0 auto;
  padding: var(--space-10);
  min-height: calc(100vh - 100px);
}

/* Desktop Navigation Tabs */
.nav-tabs {
  display: flex;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: var(--radius-2xl);
  padding: var(--space-2);
  margin-bottom: var(--space-10);
  box-shadow: var(--shadow-lg);
  width: fit-content;
  margin-left: auto;
  margin-right: auto;
}

.nav-tab {
  padding: var(--space-4) var(--space-8);
  border: none;
  background: transparent;
  color: var(--gray-600);
  font-weight: 600;
  font-size: 1rem;
  border-radius: var(--radius-xl);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: var(--space-3);
  position: relative;
  overflow: hidden;
}

.nav-tab:before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  transition: left 0.5s;
}

.nav-tab:hover:before {
  left: 100%;
}

.nav-tab.active {
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  color: white;
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.nav-tab:hover:not(.active) {
  background: var(--gray-100);
  transform: translateY(-1px);
  box-shadow: var(--shadow);
}

/* Desktop Cards */
.card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: var(--radius-2xl);
  box-shadow: var(--shadow-xl);
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.4s ease;
  overflow: hidden;
}

.card:hover {
  transform: translateY(-8px);
  box-shadow: 0 32px 64px -12px rgba(0, 0, 0, 0.25);
}

.card-header {
  padding: var(--space-8) var(--space-8) var(--space-6) var(--space-8);
  border-bottom: 2px solid var(--gray-100);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-content {
  padding: var(--space-8);
}

.card-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--gray-900);
}

/* Desktop Grid Layouts */
.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-10);
  align-items: start;
}

.grid-form {
  display: grid;
  grid-template-columns: 3fr 1fr 1fr auto;
  gap: var(--space-5);
  align-items: end;
}

/* Desktop Forms */
.form-group {
  margin-bottom: var(--space-6);
}

.form-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--gray-700);
  margin-bottom: var(--space-3);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.form-input {
  width: 100%;
  padding: var(--space-4) var(--space-5);
  border: 2px solid var(--gray-200);
  border-radius: var(--radius-lg);
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
  font-weight: 500;
}

.form-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
  transform: translateY(-2px);
}

.form-input::placeholder {
  color: var(--gray-500);
  font-weight: 400;
}

.form-select {
  width: 100%;
  padding: var(--space-4) var(--space-5);
  border: 2px solid var(--gray-200);
  border-radius: var(--radius-lg);
  font-size: 1rem;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.form-select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
  transform: translateY(-2px);
}

/* Desktop Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-8);
  border: none;
  border-radius: var(--radius-lg);
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  position: relative;
  overflow: hidden;
  min-height: 48px;
}

.btn:before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.btn:hover:before {
  left: 100%;
}

.btn:hover {
  transform: translateY(-3px);
}

.btn:active {
  transform: translateY(-1px);
}

.btn-primary {
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  color: white;
  box-shadow: var(--shadow-lg);
}

.btn-primary:hover {
  box-shadow: var(--shadow-xl);
  background: linear-gradient(135deg, var(--primary-light), var(--primary));
}

.btn-success {
  background: linear-gradient(135deg, var(--success), var(--success-light));
  color: white;
  box-shadow: var(--shadow-lg);
}

.btn-success:hover {
  box-shadow: var(--shadow-xl);
}

.btn-danger {
  background: linear-gradient(135deg, var(--danger), var(--danger-light));
  color: white;
  box-shadow: var(--shadow-lg);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn:disabled:hover {
  transform: none;
}

/* Desktop Today Hero */
.today-hero {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
  color: white;
  padding: var(--space-16) var(--space-12);
  border-radius: var(--radius-2xl);
  text-align: center;
  margin-bottom: var(--space-10);
  box-shadow: var(--shadow-xl);
  position: relative;
  overflow: hidden;
}

.today-hero:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grid" width="8" height="8" patternUnits="userSpaceOnUse"><path d="M 8 0 L 0 0 0 8" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>');
  opacity: 0.4;
}

.today-hero > * {
  position: relative;
  z-index: 1;
}

.today-title {
  font-size: 4rem;
  font-weight: 800;
  margin-bottom: var(--space-6);
  text-shadow: 0 4px 8px rgba(0,0,0,0.2);
  letter-spacing: -0.02em;
}

.today-subtitle {
  font-size: 1.5rem;
  opacity: 0.9;
  margin-bottom: var(--space-8);
  font-weight: 400;
}

/* Desktop Progress Bar */
.progress-container {
  background: rgba(255, 255, 255, 0.2);
  border-radius: var(--radius-xl);
  height: 16px;
  overflow: hidden;
  margin-bottom: var(--space-6);
  box-shadow: inset 0 4px 8px rgba(0,0,0,0.1);
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, var(--success), var(--success-light));
  border-radius: var(--radius-xl);
  transition: width 0.8s ease;
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

/* Desktop Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--space-6);
  margin-bottom: var(--space-6);
}

.stat-item {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  padding: var(--space-5) var(--space-6);
  border-radius: var(--radius-xl);
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.stat-item:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-2px);
}

.stat-value {
  font-size: 2rem;
  font-weight: 800;
  line-height: 1;
  margin-bottom: var(--space-2);
}

.stat-label {
  font-size: 0.875rem;
  opacity: 0.9;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* Desktop Task Lists */
.task-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.task-item {
  background: white;
  border-radius: var(--radius-xl);
  padding: var(--space-6);
  box-shadow: var(--shadow-md);
  border-left: 6px solid var(--gray-300);
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
}

.task-item:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-xl);
}

.task-item.priority-high {
  border-left-color: var(--danger);
}

.task-item.priority-medium {
  border-left-color: var(--warning);
}

.task-item.priority-low {
  border-left-color: var(--success);
}

.task-header {
  display: flex;
  align-items: flex-start;
  gap: var(--space-5);
  margin-bottom: var(--space-4);
}

.task-checkbox {
  width: 24px;
  height: 24px;
  border-radius: var(--radius);
  border: 3px solid var(--gray-300);
  cursor: pointer;
  position: relative;
  transition: all 0.3s ease;
  flex-shrink: 0;
  margin-top: 2px;
}

.task-checkbox:checked {
  background: var(--success);
  border-color: var(--success);
  transform: scale(1.1);
}

.task-checkbox:checked:after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 14px;
  font-weight: bold;
}

.task-content {
  flex: 1;
  min-width: 0;
}

.task-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--gray-900);
  margin-bottom: var(--space-3);
  line-height: 1.4;
}

.task-meta {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-3);
  align-items: center;
}

/* Desktop Badges */
.badge {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius);
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.badge-high {
  background: var(--danger-bg);
  color: var(--danger);
  border: 2px solid rgba(220, 38, 38, 0.2);
}

.badge-medium {
  background: var(--warning-bg);
  color: var(--warning);
  border: 2px solid rgba(217, 119, 6, 0.2);
}

.badge-low {
  background: var(--success-bg);
  color: var(--success);
  border: 2px solid rgba(5, 150, 105, 0.2);
}

.badge-overdue {
  background: var(--danger);
  color: white;
  animation: pulse 2s infinite;
}

/* Desktop Login Screen */
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-8);
}

.login-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: var(--radius-2xl);
  box-shadow: var(--shadow-xl);
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: var(--space-16);
  width: 100%;
  max-width: 500px;
  text-align: center;
}

.login-title {
  font-size: 3rem;
  font-weight: 800;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: var(--space-6);
  letter-spacing: -0.02em;
}

.login-subtitle {
  color: var(--gray-600);
  margin-bottom: var(--space-10);
  font-size: 1.25rem;
  font-weight: 500;
}

.login-form {
  text-align: left;
}

/* Loading States */
.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 500px;
  flex-direction: column;
  gap: var(--space-6);
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid var(--gray-200);
  border-top: 4px solid var(--primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideInUp {
  from { transform: translateY(100px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.fade-in {
  animation: fadeIn 0.8s ease-out;
}

.slide-in-up {
  animation: slideInUp 0.8s ease-out;
}

/* Utility Classes */
.text-center { text-align: center; }
.text-left { text-align: left; }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }
.text-xl { font-size: 1.25rem; }
.text-2xl { font-size: 1.5rem; }
.text-4xl { font-size: 2.25rem; }
.mb-2 { margin-bottom: var(--space-2); }
.mb-4 { margin-bottom: var(--space-4); }
.mb-6 { margin-bottom: var(--space-6); }
.mb-8 { margin-bottom: var(--space-8); }
.w-full { width: 100%; }

/* NO MOBILE RESPONSIVENESS - DESKTOP ONLY */
/* This design is optimized for desktop screens 1024px+ */
/* Use desktop browser for best experience */
EOF

else
    echo "🖥️ Creating DESKTOP-FIRST with proper responsive design..."
    
    # Desktop-first with proper responsive breakpoints
    cat > frontend/src/index.css << 'EOF'
/* DESKTOP-FIRST RESPONSIVE DESIGN */
/* Optimized for desktop with proper mobile adaptation */

:root {
  --primary: #2563eb;
  --primary-dark: #1d4ed8;
  --primary-light: #3b82f6;
  --primary-bg: #eff6ff;
  
  --success: #059669;
  --success-light: #10b981;
  --success-bg: #ecfdf5;
  
  --warning: #d97706;
  --warning-light: #f59e0b;
  --warning-bg: #fffbeb;
  
  --danger: #dc2626;
  --danger-light: #ef4444;
  --danger-bg: #fef2f2;
  
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-200: #e5e7eb;
  --gray-300: #d1d5db;
  --gray-500: #6b7280;
  --gray-600: #4b5563;
  --gray-700: #374151;
  --gray-800: #1f2937;
  --gray-900: #111827;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* DESKTOP STYLES (Default - 1024px and up) */
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  color: var(--gray-800);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  background-attachment: fixed;
  font-size: 14px;
}

.app {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  background-attachment: fixed;
}

.header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  padding: 1.5rem 2rem;
  position: sticky;
  top: 0;
  z-index: 50;
  box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
}

.header-content {
  max-width: 1600px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo h1 {
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.user-menu {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1.25rem;
  background: var(--gray-50);
  border-radius: 0.75rem;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 1rem;
}

.main-container {
  max-width: 1600px;
  margin: 0 auto;
  padding: 2.5rem;
  min-height: calc(100vh - 100px);
}

.nav-tabs {
  display: flex;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 1.5rem;
  padding: 0.5rem;
  margin-bottom: 2.5rem;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  width: fit-content;
  margin-left: auto;
  margin-right: auto;
}

.nav-tab {
  padding: 1rem 2rem;
  border: none;
  background: transparent;
  color: var(--gray-600);
  font-weight: 600;
  font-size: 1rem;
  border-radius: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.nav-tab.active {
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  color: white;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  transform: translateY(-2px);
}

.nav-tab:hover:not(.active) {
  background: var(--gray-100);
  transform: translateY(-1px);
}

.card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 1.5rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.4s ease;
}

.card:hover {
  transform: translateY(-8px);
  box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
}

.card-header {
  padding: 2rem 2rem 1.5rem 2rem;
  border-bottom: 2px solid var(--gray-100);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-content {
  padding: 2rem;
}

.card-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--gray-900);
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2.5rem;
  align-items: start;
}

.grid-form {
  display: grid;
  grid-template-columns: 3fr 1fr 1fr auto;
  gap: 1.25rem;
  align-items: end;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--gray-700);
  margin-bottom: 0.75rem;
}

.form-input {
  width: 100%;
  padding: 1rem 1.25rem;
  border: 2px solid var(--gray-200);
  border-radius: 0.75rem;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
}

.form-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
  transform: translateY(-2px);
}

.form-select {
  width: 100%;
  padding: 1rem 1.25rem;
  border: 2px solid var(--gray-200);
  border-radius: 0.75rem;
  font-size: 1rem;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
}

.form-select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  padding: 1rem 2rem;
  border: none;
  border-radius: 0.75rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  min-height: 48px;
}

.btn:hover {
  transform: translateY(-3px);
}

.btn-primary {
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  color: white;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.btn-primary:hover {
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
}

.btn-success {
  background: linear-gradient(135deg, var(--success), var(--success-light));
  color: white;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.today-hero {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
  color: white;
  padding: 4rem 3rem;
  border-radius: 1.5rem;
  text-align: center;
  margin-bottom: 2.5rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
}

.today-title {
  font-size: 4rem;
  font-weight: 800;
  margin-bottom: 1.5rem;
  text-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.today-subtitle {
  font-size: 1.5rem;
  opacity: 0.9;
  margin-bottom: 2rem;
}

.progress-container {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 1rem;
  height: 16px;
  overflow: hidden;
  margin-bottom: 1.5rem;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, var(--success), var(--success-light));
  border-radius: 1rem;
  transition: width 0.8s ease;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.stat-item {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  padding: 1.25rem 1.5rem;
  border-radius: 1rem;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.stat-value {
  font-size: 2rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
}

.stat-label {
  font-size: 0.875rem;
  opacity: 0.9;
}

.task-list {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.task-item {
  background: white;
  border-radius: 1rem;
  padding: 1.5rem;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  border-left: 6px solid var(--gray-300);
  transition: all 0.4s ease;
}

.task-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
}

.task-item.priority-high { border-left-color: var(--danger); }
.task-item.priority-medium { border-left-color: var(--warning); }
.task-item.priority-low { border-left-color: var(--success); }

.task-header {
  display: flex;
  align-items: flex-start;
  gap: 1.25rem;
  margin-bottom: 1rem;
}

.task-checkbox {
  width: 24px;
  height: 24px;
  border-radius: 0.5rem;
  border: 3px solid var(--gray-300);
  cursor: pointer;
  transition: all 0.3s ease;
  flex-shrink: 0;
  margin-top: 2px;
}

.task-checkbox:checked {
  background: var(--success);
  border-color: var(--success);
}

.task-content {
  flex: 1;
}

.task-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--gray-900);
  margin-bottom: 0.75rem;
  line-height: 1.4;
}

.task-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  align-items: center;
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
}

.badge-high { background: var(--danger-bg); color: var(--danger); }
.badge-medium { background: var(--warning-bg); color: var(--warning); }
.badge-low { background: var(--success-bg); color: var(--success); }

.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.login-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 1.5rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: 4rem;
  width: 100%;
  max-width: 500px;
  text-align: center;
}

.login-title {
  font-size: 3rem;
  font-weight: 800;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 1.5rem;
}

.login-subtitle {
  color: var(--gray-600);
  margin-bottom: 2.5rem;
  font-size: 1.25rem;
}

.login-form {
  text-align: left;
}

.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 500px;
  flex-direction: column;
  gap: 1.5rem;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid var(--gray-200);
  border-top: 4px solid var(--primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in { animation: fadeIn 0.8s ease-out; }
.slide-in-up { animation: fadeIn 0.8s ease-out; }

.text-center { text-align: center; }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }
.text-xl { font-size: 1.25rem; }
.text-2xl { font-size: 1.5rem; }
.text-4xl { font-size: 2.25rem; }
.mb-4 { margin-bottom: 1rem; }
.mb-6 { margin-bottom: 1.5rem; }
.mb-8 { margin-bottom: 2rem; }
.w-full { width: 100%; }

/* TABLET RESPONSIVE (768px - 1023px) */
@media (max-width: 1023px) {
  .main-container {
    padding: 1.5rem;
  }
  
  .grid-2 {
    grid-template-columns: 1fr;
    gap: 2rem;
  }
  
  .grid-form {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .today-title {
    font-size: 3rem;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* MOBILE RESPONSIVE (767px and below) */
@media (max-width: 767px) {
  .header {
    padding: 1rem;
  }
  
  .header-content {
    flex-direction: column;
    gap: 1rem;
  }
  
  .main-container {
    padding: 1rem;
  }
  
  .nav-tabs {
    width: 100%;
    justify-content: center;
  }
  
  .nav-tab {
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
  }
  
  .today-hero {
    padding: 2rem 1rem;
  }
  
  .today-title {
    font-size: 2.5rem;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .card-content {
    padding: 1rem;
  }
  
  .form-input,
  .form-select,
  .btn {
    min-height: 44px;
    font-size: 16px; /* Prevents iOS zoom */
  }
  
  .login-card {
    padding: 2rem;
  }
  
  .login-title {
    font-size: 2rem;
  }
}
EOF
fi

echo "📱 Step 6: Committing the fixed desktop design..."

git add frontend/src/index.css

if [ "$choice" = "1" ]; then
    git commit -m "Fix desktop design - DESKTOP-ONLY with no mobile support"
    echo ""
    echo "🖥️ DESKTOP-ONLY DESIGN COMPLETE!"
    echo ""
    echo "✅ WHAT YOU NOW HAVE:"
    echo "• 🖥️ Pure desktop-only interface (no mobile support)"
    echo "• 💎 Beautiful professional desktop design"
    echo "• 🎨 Modern glassmorphism with backdrop blur effects"
    echo "• ⚡ Smooth animations and hover effects"
    echo "• 📊 Desktop-optimized layouts and spacing"
    echo "• 🔘 Professional buttons and forms"
    echo ""
    echo "⚠️  MOBILE USERS:"
    echo "• 📱 This design is NOT mobile-friendly"
    echo "• 🖥️ Mobile users should use desktop browser"
    echo "• 💻 Best viewed on screens 1024px and larger"
else
    git commit -m "Fix desktop design - Proper desktop-first with smart mobile responsiveness"
    echo ""
    echo "🖥️ DESKTOP-FIRST RESPONSIVE DESIGN COMPLETE!"
    echo ""
    echo "✅ WHAT YOU NOW HAVE:"
    echo "• 🖥️ Beautiful professional desktop design (primary focus)"
    echo "• 📱 Smart responsive design that doesn't ruin desktop"
    echo "• 💎 Modern glassmorphism with backdrop blur"
    echo "• ⚡ Smooth animations and professional interactions"
    echo ""
    echo "📊 BREAKPOINTS:"
    echo "• 🖥️ Desktop (1024px+): Full professional layout"
    echo "• 📱 Tablet (768px-1023px): Two-column to single column"
    echo "• 📱 Mobile (< 768px): Touch-friendly single column"
fi

git push origin main

echo ""
echo "🚀 YOUR DESKTOP DESIGN IS NOW FIXED!"
echo ""
echo "🎯 DESKTOP EXPERIENCE:"
echo "• 💼 Professional business application appearance"
echo "• 🎨 Beautiful gradients and modern design"
echo "• 📊 Proper desktop layouts with good use of space"
echo "• 🔘 Desktop-sized buttons and forms"
echo "• ⚡ Smooth hover effects and animations"
echo "• 💎 Glass morphism cards with backdrop blur"
echo ""
echo "🔄 Render will auto-deploy these changes."
echo "Your app now prioritizes desktop experience! ✨"
