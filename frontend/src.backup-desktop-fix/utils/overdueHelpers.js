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
