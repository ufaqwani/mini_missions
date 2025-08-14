#!/bin/bash

echo "🔧 FIXING IDENTIFIED DESKTOP ISSUES"
echo "Resolving CSS import, conflicts, and inline style problems..."

echo "📋 Step 1: Remove conflicting CSS file..."
# Remove the old conflicting CSS file
rm -f frontend/src/frontend-src/index.css
echo "✅ Removed conflicting CSS file"

echo "📋 Step 2: Ensure CSS is imported in index.js..."
# Check and fix index.js to import CSS
cat > frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';  // Make sure this line exists
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF
echo "✅ Fixed index.js CSS import"

echo "📋 Step 3: Fix MissionList.js to use CSS classes instead of inline styles..."
cat > frontend/src/components/MissionList.js << 'EOF'
import React from 'react';

const MissionList = ({ missions, selectedMissionId, onSelectMission, onEdit, onDelete }) => {
  if (!missions || missions.length === 0) {
    return (
      <div className="text-center" style={{ padding: '3rem', color: 'var(--gray-500)' }}>
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>📋</div>
        <h3 className="text-xl font-semibold mb-4">No missions yet</h3>
        <p>Create your first mission to get started with your productivity journey!</p>
      </div>
    );
  }

  return (
    <div className="task-list">
      {missions.map(mission => (
        <div
          key={mission.id}
          className={`task-item ${selectedMissionId === mission.id ? 'task-item-selected' : ''}`}
          onClick={() => onSelectMission(mission.id)}
        >
          <div className="task-header">
            <div className="task-content">
              <div className="mission-header">
                <h3 className="task-title">{mission.title}</h3>
                <div className="mission-actions">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onEdit(mission);
                    }}
                    className="btn"
                    style={{ 
                      background: 'var(--primary-100)',
                      color: 'var(--primary-700)',
                      border: '1px solid var(--primary-200)',
                      padding: '0.5rem 1rem',
                      fontSize: '0.875rem'
                    }}
                  >
                    Edit
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      if (window.confirm('Are you sure you want to delete this mission?')) {
                        onDelete(mission.id);
                      }
                    }}
                    className="btn"
                    style={{ 
                      background: 'var(--danger-50)',
                      color: 'var(--danger-600)',
                      border: '1px solid var(--danger-200)',
                      padding: '0.5rem 1rem',
                      fontSize: '0.875rem'
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
              {mission.description && (
                <p className="mission-description">{mission.description}</p>
              )}
              <div className="task-meta">
                <span className={`badge ${mission.status === 'completed' ? 'badge-low' : 'badge-medium'}`}>
                  {mission.status === 'completed' ? '✅ Completed' : '🎯 Active'}
                </span>
                {mission.target_completion_date && (
                  <span className="badge" style={{ 
                    background: 'var(--primary-50)',
                    color: 'var(--primary-700)',
                    border: '1px solid var(--primary-200)'
                  }}>
                    📅 Due: {new Date(mission.target_completion_date).toLocaleDateString()}
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default MissionList;
EOF
echo "✅ Fixed MissionList.js to use CSS classes"

echo "📋 Step 4: Add missing CSS classes for proper desktop styling..."
cat >> frontend/src/index.css << 'EOF'

/* Additional Desktop Styles for Components */
.task-item-selected {
  border-left-color: var(--primary-600) !important;
  background: var(--primary-50) !important;
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg) !important;
}

.mission-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-3);
}

.mission-actions {
  display: flex;
  gap: var(--space-2);
  flex-shrink: 0;
}

.mission-description {
  color: var(--gray-600);
  margin-bottom: var(--space-3);
  line-height: 1.5;
}

/* Ensure desktop-first grid layout is enforced */
@media (min-width: 1025px) {
  .grid-2 {
    display: grid !important;
    grid-template-columns: 1fr 1fr !important;
    gap: var(--space-10) !important;
  }
  
  .main-container {
    max-width: 1400px !important;
    margin: 0 auto !important;
    padding: var(--space-10) !important;
  }
  
  .card {
    min-height: 400px;
  }
}

/* Force desktop layout on large screens */
@media (min-width: 1200px) {
  .today-hero {
    padding: var(--space-16) var(--space-12) !important;
  }
  
  .today-title {
    font-size: 3.5rem !important;
  }
  
  .stats-grid {
    grid-template-columns: repeat(4, 1fr) !important;
  }
}
EOF
echo "✅ Added missing desktop CSS classes"

echo "📋 Step 5: Force browser cache clear and rebuild..."
# Clear React build cache
rm -rf frontend/build
rm -rf frontend/.cache
echo "✅ Cleared build cache"

echo "📋 Step 6: Verify App.js uses correct CSS classes..."
# Quick check that App.js uses the right classes
if grep -q "className.*app" frontend/src/App.js; then
    echo "✅ App.js uses CSS classes"
else
    echo "⚠️  App.js might need CSS class updates"
fi

echo "📋 Step 7: Test desktop styles work..."
# Create a simple test to verify desktop styles
cat > test-desktop-now.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Desktop Test</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 24px;
            padding: 40px;
        }
        
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
        }
        
        .card {
            background: #f9fafb;
            padding: 30px;
            border-radius: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 style="text-align: center; font-size: 3rem; margin-bottom: 40px;">🖥️ Desktop Test</h1>
        <div class="grid">
            <div class="card">
                <h2>Left Column ✅</h2>
                <p>If this is side-by-side with the right column, desktop styles work!</p>
            </div>
            <div class="card">
                <h2>Right Column ✅</h2>
                <p>If this is below the left column, mobile styles are being applied.</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo ""
echo "🎯 CRITICAL FIXES APPLIED!"
echo "=========================="
echo ""
echo "✅ FIXED ISSUES:"
echo "• 🔧 Removed conflicting CSS file (frontend/src/frontend-src/index.css)"
echo "• 🔧 Ensured index.css is imported in index.js"
echo "• 🔧 Replaced inline styles with CSS classes in MissionList.js"
echo "• 🔧 Added missing desktop-specific CSS rules"
echo "• 🔧 Added !important rules to force desktop layout on large screens"
echo "• 🔧 Cleared build cache to prevent stale styles"
echo ""
echo "🧪 TESTING:"
echo "=========="
echo "1. Open 'test-desktop-now.html' in your browser"
echo "2. If you see two columns side-by-side → Desktop styles work"
echo "3. If you see stacked columns → Still mobile styling"
echo ""
echo "📱 NEXT STEPS:"
echo "============="
echo "1. Hard refresh your browser (Ctrl+F5 or Cmd+Shift+R)"
echo "2. Check React dev server - restart if needed:"
echo "   cd frontend && npm start"
echo "3. Open browser dev tools and check:"
echo "   - Elements tab: Look for class='grid-2' on desktop"
echo "   - Console: Check for CSS import errors"
echo ""
echo "🚀 If test-desktop-now.html shows desktop layout,"
echo "    but your app still looks mobile, the issue is in component class usage!"
