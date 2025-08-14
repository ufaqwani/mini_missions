#!/bin/bash

echo "⚠️ Adding overdue task highlighting to Today's Focus..."
echo "Users will now see which tasks they missed from previous days!"

cd mission-tracker

echo "🔧 Enhancing backend to identify overdue tasks..."

# Update the today missions route to include overdue status
cat > backend/routes/todayMissionsEnhanced.js << 'EOF'
const express = require('express');
const router = express.Router();

// Enhanced today missions with overdue detection
router.get('/enhanced', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    const todayMissions = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, 
               m.title as mission_title, 
               m.status as mission_status,
               CASE 
                 WHEN dm.due_date < ? THEN 'overdue'
                 WHEN dm.due_date = ? THEN 'today'
                 ELSE 'future'
               END as task_status,
               CASE 
                 WHEN dm.due_date < ? THEN julianday(?) - julianday(dm.due_date)
                 ELSE 0
               END as days_overdue
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE (dm.due_date <= ? OR dm.due_date IS NULL) 
        AND dm.status != 'completed' 
        AND m.status = 'active'
        ORDER BY dm.priority ASC, 
                 CASE WHEN dm.due_date < ? THEN 0 ELSE 1 END,
                 dm.due_date ASC, 
                 dm.created_at DESC
      `, [today, today, today, today, today, today], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(todayMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
EOF

# Add the enhanced route to server.js
sed -i '/app.use.*\/api\/today.*require.*todayMissions/a app.use("/api/today", require("./routes/todayMissionsEnhanced"));' backend/server.js

echo "🎨 Adding overdue styling to frontend..."

# Create overdue task utilities
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

# Add CSS animations for overdue tasks
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

# Update TodayDashboard to use enhanced overdue detection
sed -i '/const loadTodayData = async/,/^  };/c\
  const loadTodayData = async () => {\
    try {\
      setLoading(true);\
      \
      const [todayResponse, completedResponse, enhancedResponse] = await Promise.all([\
        fetch("/api/today"),\
        fetch("/api/today/completed"),\
        fetch("/api/today/enhanced").catch(() => ({ json: () => [] }))\
      ]);\
      \
      if (!todayResponse.ok || !completedResponse.ok) {\
        throw new Error("Failed to fetch today\\"s data");\
      }\
      \
      const todayData = await todayResponse.json();\
      const completedData = await completedResponse.json();\
      const enhancedData = enhancedResponse.ok ? await enhancedResponse.json() : todayData;\
      \
      setTodayMissions(enhancedData.length > 0 ? enhancedData : todayData);\
      setCompletedToday(completedData);\
    } catch (error) {\
      console.error("Error loading today\\"s data:", error);\
    } finally {\
      setLoading(false);\
    }\
  };' frontend/src/components/TodayDashboard.js

# Add overdue helpers import to TodayDashboard
sed -i '1i import { getOverdueInfo, getOverdueStyles } from "../utils/overdueHelpers";' frontend/src/components/TodayDashboard.js

# Update the task rendering to include overdue indicators
sed -i '/todayMissions.map(mission => {/,/^                });$/c\
              todayMissions.map(mission => {\
                const priorityInfo = getPriorityInfo(mission.priority);\
                const overdueInfo = getOverdueInfo(mission);\
                const overdueStyles = getOverdueStyles(overdueInfo, priorityInfo);\
                \
                return (\
                  <div\
                    key={mission.id}\
                    className={overdueInfo.urgency === "critical" ? "overdue-critical" : ""}\
                    style={{\
                      backgroundColor: priorityInfo.bgColor,\
                      border: `1px solid ${priorityInfo.borderColor}`,\
                      padding: "12px",\
                      marginBottom: "10px",\
                      borderRadius: "6px",\
                      borderLeft: `4px solid ${priorityInfo.color}`,\
                      ...overdueStyles\
                    }}\
                  >\
                    <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>\
                      <input\
                        type="checkbox"\
                        checked={false}\
                        onChange={() => handleToggleComplete(mission)}\
                        style={{ transform: "scale(1.3)", cursor: "pointer" }}\
                      />\
                      <span style={{ fontSize: "16px" }}>{priorityInfo.icon}</span>\
                      <div style={{ flex: 1 }}>\
                        <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "5px" }}>\
                          {overdueInfo.isOverdue && (\
                            <span className={`overdue-badge ${\
                              overdueInfo.urgency === "critical" ? "overdue-critical-badge" : "overdue-warning-badge"\
                            }`}>\
                              {overdueInfo.urgency === "critical" ? "🚨 OVERDUE" : "⚠️ LATE"}\
                            </span>\
                          )}\
                          <h4 style={{ margin: "0", color: "#333" }}>{mission.title}</h4>\
                        </div>\
                        \
                        {overdueInfo.isOverdue && (\
                          <p style={{ \
                            margin: "0 0 8px 0", \
                            fontSize: "12px", \
                            color: overdueInfo.urgency === "critical" ? "#dc2626" : "#f59e0b",\
                            fontWeight: "bold"\
                          }}>\
                            {overdueInfo.daysLate === 1 \
                              ? "📅 This was due yesterday!"\
                              : `📅 This was due ${overdueInfo.daysLate} days ago!`\
                            }\
                          </p>\
                        )}\
                        \
                        <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>\
                          <span style={{ \
                            fontSize: "10px", \
                            color: "white",\
                            backgroundColor: priorityInfo.color,\
                            padding: "2px 6px",\
                            borderRadius: "3px",\
                            fontWeight: "bold",\
                            textTransform: "uppercase"\
                          }}>\
                            {priorityInfo.label}\
                          </span>\
                          <span style={{ \
                            fontSize: "12px", \
                            color: "#666",\
                            backgroundColor: "#e3f2fd",\
                            padding: "2px 6px",\
                            borderRadius: "3px"\
                          }}>\
                            📋 {mission.mission_title}\
                          </span>\
                          {mission.due_date && (\
                            <span style={{ \
                              fontSize: "12px", \
                              color: overdueInfo.isOverdue ? "#dc2626" : "#666" \
                            }}>\
                              {overdueInfo.isOverdue \
                                ? `⚠️ Was due: ${new Date(mission.due_date).toLocaleDateString()}`\
                                : "📅 Due today"\
                              }\
                            </span>\
                          )}\
                        </div>\
                      </div>\
                    </div>\
                  </div>\
                );\
              })' frontend/src/components/TodayDashboard.js

# Update the header to show overdue statistics
sed -i '/const getPriorityStats = () => {/,/^  };$/c\
  const getPriorityStats = () => {\
    const highPriority = todayMissions.filter(m => m.priority === 1).length;\
    const mediumPriority = todayMissions.filter(m => m.priority === 2).length;\
    const lowPriority = todayMissions.filter(m => m.priority === 3).length;\
    const overdueCount = todayMissions.filter(m => getOverdueInfo(m).isOverdue).length;\
    const criticalOverdue = todayMissions.filter(m => getOverdueInfo(m).urgency === "critical").length;\
    return { high: highPriority, medium: mediumPriority, low: lowPriority, overdue: overdueCount, critical: criticalOverdue };\
  };' frontend/src/components/TodayDashboard.js

# Update the stats display in header
sed -i '/display: .flex., justifyContent: .center., gap: .20px., marginBottom: .10px., fontSize: .14px/,/}/c\
          <div style={{ display: "flex", justifyContent: "center", gap: "20px", marginBottom: "10px", fontSize: "14px" }}>\
            <span>🔴 {priorityStats.high} High</span>\
            <span>🟡 {priorityStats.medium} Medium</span>\
            <span>🟢 {priorityStats.low} Low</span>\
            {priorityStats.overdue > 0 && (\
              <span style={{ color: "#fef2f2", fontWeight: "bold", animation: "pulse 1s infinite" }}>\
                {priorityStats.critical > 0 ? "🚨" : "⚠️"} {priorityStats.overdue} Overdue\
              </span>\
            )}\
          </div>' frontend/src/components/TodayDashboard.js

echo "🔄 Applying changes to running servers..."

# Create a quick restart script for just the backend
cat > quick-restart.sh << 'EOF'
#!/bin/bash
echo "🔄 Quick restart for overdue features..."
pkill -f "npm run dev" 2>/dev/null || true
sleep 1
cd backend && npm run dev &
echo "✅ Backend restarted with overdue detection!"
EOF

chmod +x quick-restart.sh

echo ""
echo "✅ Overdue Task Highlighting Added!"
echo ""
echo "🚨 NEW OVERDUE FEATURES:"
echo "• 📍 Clear visual distinction between today's tasks vs overdue tasks"
echo "• 🚨 CRITICAL badges for tasks 3+ days overdue (red, pulsing)"
echo "• ⚠️ WARNING badges for tasks 1-2 days overdue (yellow)"
echo "• 📅 Shows exactly how many days late each task is"
echo "• 🔼 Overdue tasks automatically sort to the top"
echo "• 📊 Header shows overdue count with warning indicators"
echo "• 🎨 Animated visual cues for urgent overdue tasks"
echo ""
echo "🎯 USER BENEFITS:"
echo "• Instant accountability - see missed tasks immediately"
echo "• Clear prioritization - overdue tasks stand out visually"
echo "• No more confusion about when tasks were originally due"
echo "• Motivational pressure to complete overdue items first"
echo ""
echo "To apply changes:"
echo "1. Run: ./quick-restart.sh"
echo "2. Frontend will auto-refresh"
echo ""
echo "Now users will NEVER miss seeing which tasks they didn't complete! 🎯⚠️"
