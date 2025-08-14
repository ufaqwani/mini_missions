#!/bin/bash

echo "🔍 STEP-BY-STEP DIAGNOSTIC - FINDING THE ROOT PROBLEM"
echo "Let's systematically check what's actually happening..."

echo ""
echo "📋 STEP 1: CHECKING PROJECT STRUCTURE"
echo "======================================"
echo "Current directory structure:"
ls -la
echo ""
echo "Frontend structure:"
ls -la frontend/
echo ""
echo "Frontend src structure:"
ls -la frontend/src/
echo ""
echo "CSS file check:"
if [ -f "frontend/src/index.css" ]; then
    echo "✅ index.css exists"
    echo "File size: $(wc -c < frontend/src/index.css) bytes"
    echo "Last modified: $(stat -c %y frontend/src/index.css)"
else
    echo "❌ index.css NOT FOUND"
fi

echo ""
echo "📋 STEP 2: CHECKING CSS CONTENT"
echo "==============================="
echo "First 20 lines of current CSS:"
head -20 frontend/src/index.css
echo ""
echo "CSS contains desktop styles? Let's check for key desktop indicators:"
grep -n "desktop\|1024px\|max-width.*1400\|grid-template-columns.*1fr 1fr" frontend/src/index.css | head -5

echo ""
echo "📋 STEP 3: CHECKING VIEWPORT META TAG"
echo "====================================="
echo "Current viewport in index.html:"
if [ -f "frontend/public/index.html" ]; then
    grep -n "viewport" frontend/public/index.html
else
    echo "❌ index.html not found"
fi

echo ""
echo "📋 STEP 4: CHECKING IF CSS IS IMPORTED IN APP"
echo "============================================="
echo "Checking if index.css is imported in index.js:"
if [ -f "frontend/src/index.js" ]; then
    grep -n "index.css\|\.css" frontend/src/index.js
else
    echo "❌ index.js not found"
fi

echo ""
echo "📋 STEP 5: CHECKING FOR CSS CONFLICTS"
echo "====================================="
echo "Looking for other CSS files that might conflict:"
find frontend/src -name "*.css" -type f
echo ""
echo "Checking for inline styles in components:"
grep -r "style={{" frontend/src/components/ | head -5

echo ""
echo "📋 STEP 6: CHECKING RECENT GIT COMMITS"
echo "======================================"
echo "Last 3 commits:"
git log --oneline -3

echo ""
echo "📋 STEP 7: CHECKING CURRENT APP.JS STRUCTURE"
echo "==========================================="
echo "App.js main container classes:"
grep -n "className.*app\|className.*container\|className.*main" frontend/src/App.js | head -5

echo ""
echo "📋 STEP 8: TESTING CSS SELECTOR PRIORITY"
echo "======================================="
echo "Checking for potentially overriding selectors:"
grep -n "\* {" frontend/src/index.css
grep -n "body {" frontend/src/index.css
grep -n "\.app {" frontend/src/index.css

echo ""
echo "📋 STEP 9: CHECKING PACKAGE.JSON BUILD SCRIPTS"
echo "=============================================="
echo "Frontend package.json scripts:"
if [ -f "frontend/package.json" ]; then
    grep -A 5 '"scripts"' frontend/package.json
else
    echo "❌ frontend package.json not found"
fi

echo ""
echo "📋 STEP 10: CHECKING FOR MOBILE-FIRST INDICATORS"
echo "==============================================="
echo "Looking for mobile-first CSS patterns:"
grep -n "@media.*max-width.*768\|@media.*max-width.*480" frontend/src/index.css | head -3
echo ""
echo "Looking for potential mobile-first problems:"
grep -n "min-width.*100vw\|max-width.*100vw\|flex-direction.*column" frontend/src/index.css | head -3

echo ""
echo "🚨 STEP 11: IDENTIFYING THE MAIN ISSUES"
echo "======================================="

# Check if CSS is actually desktop-first
DESKTOP_STYLES=$(grep -c "max-width.*1400\|grid-template-columns.*1fr 1fr\|padding.*var(--space-10)" frontend/src/index.css)
MOBILE_RESPONSIVE=$(grep -c "@media.*max-width" frontend/src/index.css)

echo "Desktop-style indicators found: $DESKTOP_STYLES"
echo "Mobile responsive breakpoints: $MOBILE_RESPONSIVE"

if [ $DESKTOP_STYLES -lt 5 ]; then
    echo "❌ ISSUE FOUND: Not enough desktop-first styles"
fi

# Check for common mobile-first problems
if grep -q "width.*100%" frontend/src/index.css; then
    echo "⚠️  POTENTIAL ISSUE: Full-width elements detected"
fi

if grep -q "flex-direction.*column" frontend/src/index.css; then
    echo "⚠️  POTENTIAL ISSUE: Column flex direction (mobile-style) detected"
fi

# Check viewport
if grep -q "user-scalable=no" frontend/public/index.html; then
    echo "⚠️  POTENTIAL ISSUE: Mobile viewport settings detected"
fi

echo ""
echo "📋 STEP 12: CREATING SIMPLE TEST FILE"
echo "===================================="

# Create a simple test HTML to verify our styles work
cat > test-desktop-styles.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Desktop Style Test</title>
    <style>
        /* Test Desktop Styles */
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .test-container {
            max-width: 1400px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 24px;
            padding: 40px;
            box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
        }
        
        .test-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            margin: 40px 0;
        }
        
        .test-card {
            background: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
        }
        
        h1 {
            font-size: 3rem;
            text-align: center;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .status {
            padding: 20px;
            background: #ecfdf5;
            border: 2px solid #10b981;
            border-radius: 12px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="test-container">
        <h1>🖥️ Desktop Style Test</h1>
        <div class="status">
            <h2>✅ If you can see this properly formatted, desktop styles work!</h2>
            <p>This should show: Large title, two-column grid below, professional spacing</p>
        </div>
        <div class="test-grid">
            <div class="test-card">
                <h3>Column 1</h3>
                <p>This should be in a two-column layout on desktop screens wider than 1024px.</p>
            </div>
            <div class="test-card">
                <h3>Column 2</h3>
                <p>If this is below Column 1 instead of side-by-side, then mobile styles are being applied.</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "✅ Created test-desktop-styles.html - Open this in your browser to test if desktop styles work"
echo ""

echo "📋 STEP 13: CURRENT DIAGNOSIS SUMMARY"
echo "==================================="
echo ""
echo "🔍 ANALYSIS COMPLETE! Based on the diagnostics:"
echo ""

# Generate diagnosis
if [ ! -f "frontend/src/index.css" ]; then
    echo "🚨 CRITICAL: CSS file is missing!"
elif [ $(wc -c < frontend/src/index.css) -lt 1000 ]; then
    echo "🚨 CRITICAL: CSS file is too small (likely empty or corrupted)"
elif [ $DESKTOP_STYLES -lt 3 ]; then
    echo "🚨 CRITICAL: CSS doesn't contain proper desktop styles"
else
    echo "💡 CSS file exists and has some desktop styles..."
fi

echo ""
echo "📋 NEXT STEPS - CHOOSE YOUR FIX:"
echo "=============================="
echo ""
echo "Based on the diagnosis above, here are the likely issues and fixes:"
echo ""
echo "1. 🔧 If CSS is missing/corrupted: We need to recreate the CSS file"
echo "2. 🔧 If viewport is wrong: We need to fix the meta tag"
echo "3. 🔧 If styles aren't loading: We need to check imports"
echo "4. 🔧 If cache issues: We need to clear and rebuild"
echo ""
echo "📊 WHAT TO DO NEXT:"
echo "==================="
echo ""
echo "1. First, open 'test-desktop-styles.html' in your browser"
echo "2. If that shows mobile layout, the problem is browser/system level"
echo "3. If that shows desktop layout, the problem is in our React app"
echo ""
echo "🎯 Tell me what you see when you open test-desktop-styles.html"
echo "and I'll give you the exact fix needed!"

