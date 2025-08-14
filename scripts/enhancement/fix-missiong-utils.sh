#!/bin/bash

echo "🔧 Creating missing utils folder and overdueHelpers.js file..."

cd mission-tracker

# Create the utils directory if it doesn't exist
mkdir -p frontend/src/utils

echo "📁 Created utils folder"

# Create the overdueHelpers.js file with all the required functions
cat > frontend/src/utils/overdueHelpers.js << 'EOF'
export const getOverdueInfo = (task) => {
  const today = new Date().toISOString().split('T')[0];
  const taskDate = task.due_date;
  
  if (!taskDate) return { isOverdue: false, daysLate: 0, urgency: 'none' };
  
  const isOverdue = taskDate < today;
  const daysLate = isOverdue ? Math.floor((new Date(today) - new Date(taskDate)) / (1000 * 60 * 60 * 24)) : 0;
  
  let urgency = 'none';
  if (daysLate >= 3) urgency = 'critical';
  else if (daysLate >= 1) urgency = 'warning';
  
  return { isOverdue, daysLate, urgency };
};

export const getOverdueStyles = (overdueInfo, priorityInfo) => {
  if (!overdueInfo.isOverdue) return {};
  
  const baseStyle = {
    position: 'relative',
    animation: 'pulse 2s infinite',
  };
  
  if (overdueInfo.urgency === 'critical') {
    return {
      ...baseStyle,
      backgroundColor: '#fef2f2',
      border: '2px solid #dc2626',
      boxShadow: '0 0 0 3px rgba(220, 38, 38, 0.1)',
    };
  } else if (overdueInfo.urgency === 'warning') {
    return {
      ...baseStyle,
      backgroundColor: '#fffbeb',
      border: '2px solid #f59e0b',
      boxShadow: '0 0 0 3px rgba(245, 158, 11, 0.1)',
    };
  }
  
  return baseStyle;
};
EOF

echo "✅ Created overdueHelpers.js with all required functions"

# Also create the CSS file that was referenced
cat >> frontend/src/index.css << 'EOF'

/* Overdue task animations */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}

@keyframes urgentPulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.02); }
}

.overdue-critical {
  animation: urgentPulse 1.5s infinite;
}

.overdue-badge {
  font-size: 10px;
  font-weight: bold;
  padding: 2px 6px;
  border-radius: 3px;
  text-transform: uppercase;
  margin-right: 5px;
}

.overdue-critical-badge {
  background-color: #dc2626;
  color: white;
  animation: pulse 1s infinite;
}

.overdue-warning-badge {
  background-color: #f59e0b;
  color: white;
}
EOF

echo "✅ Added CSS animations for overdue tasks"

echo ""
echo "🎯 FIXED THE MODULE ERROR!"
echo ""
echo "✅ Created missing utils folder: frontend/src/utils/"
echo "✅ Created overdueHelpers.js with getOverdueInfo() and getOverdueStyles() functions"
echo "✅ Added CSS animations for overdue task styling"
echo ""
echo "The compilation error should now be resolved! 🚀"
echo "Your React app should compile successfully with all overdue functionality working."
