// SECURE Authentication - NO PASSWORD EXPOSURE
const USERS = {
  'ufaq': 'ufitufy',
  'zia': 'zeetv', 
  'sweta': 'ss786'
};

const authenticateUser = (req, res, next) => {
  const currentUser = req.headers['x-current-user'];
  
  if (!currentUser || !USERS[currentUser]) {
    return res.status(401).json({ 
      error: 'Authentication required',
      success: false 
    });
  }
  
  req.user = { username: currentUser };
  next();
};

const loginUser = (req, res) => {
  const { username, password } = req.body;
  
  // Validate credentials - NEVER send passwords back
  if (USERS[username] && USERS[username] === password) {
    res.json({ 
      success: true, 
      user: { username }, // ONLY send username, NEVER password
      message: 'Authentication successful' 
    });
  } else {
    res.status(401).json({ 
      success: false, 
      error: 'Invalid credentials' // Generic error message
    });
  }
};

// NEVER expose password list or user details
module.exports = { authenticateUser, loginUser };
