// Simple hardcoded user authentication
const USERS = {
  'ufaq': 'ufitufy',
  'zia': 'zeetv', 
  'sweta': 'ss786'
};

const authenticateUser = (req, res, next) => {
  // Get current user from session/header
  const currentUser = req.headers['x-current-user'];
  
  if (!currentUser || !USERS[currentUser]) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  
  req.user = { username: currentUser };
  next();
};

const loginUser = (req, res) => {
  const { username, password } = req.body;
  
  if (USERS[username] && USERS[username] === password) {
    res.json({ 
      success: true, 
      user: { username },
      message: 'Login successful' 
    });
  } else {
    res.status(401).json({ 
      success: false, 
      error: 'Invalid username or password' 
    });
  }
};

module.exports = { authenticateUser, loginUser, USERS };
