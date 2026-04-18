# 📱 GitHub CLI - Installation & Usage Guide

## Do You Need GitHub CLI?

### **Answer: NO, it's OPTIONAL**

**For the basic fix (recommended for most users):**
```bash
./auto_fix_github_actions.sh
```
✅ Uses regular git commands (already installed)
✅ Fixes the workflow
✅ Pushes to GitHub
✅ Opens browser to Actions page
✅ **No GitHub CLI needed!**

---

**For enhanced monitoring (optional for power users):**
```bash
./auto_fix_github_actions_enhanced.sh
```
✅ Everything from basic version
✅ PLUS: Real-time workflow monitoring
✅ PLUS: Command-line run viewing
✅ PLUS: Direct artifact downloads
⚠️ **Requires GitHub CLI**

---

## GitHub CLI Installation (Optional)

### **macOS**

```bash
# Using Homebrew (recommended)
brew install gh

# Or using MacPorts
sudo port install gh

# Verify installation
gh --version
```

---

### **Linux**

#### **Ubuntu/Debian:**
```bash
# Add GitHub CLI repository
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install
sudo apt update
sudo apt install gh

# Verify
gh --version
```

#### **Fedora/RHEL/CentOS:**
```bash
sudo dnf install gh

# Verify
gh --version
```

#### **Arch Linux:**
```bash
sudo pacman -S github-cli

# Verify
gh --version
```

---

### **Windows**

#### **Using winget:**
```powershell
winget install --id GitHub.cli

# Verify
gh --version
```

#### **Using Chocolatey:**
```powershell
choco install gh

# Verify
gh --version
```

#### **Using Scoop:**
```powershell
scoop install gh

# Verify
gh --version
```

---

## Authentication (Required After Installation)

After installing GitHub CLI, you need to authenticate:

```bash
# Start authentication
gh auth login

# Follow the prompts:
# 1. Choose: GitHub.com
# 2. Choose: HTTPS (or SSH if you prefer)
# 3. Authenticate with: Login with a web browser (recommended)
# 4. Copy the one-time code shown
# 5. Press Enter to open browser
# 6. Paste code and authorize

# Verify authentication
gh auth status
```

**Expected output:**
```
✓ Logged in to github.com as YOUR_USERNAME
✓ Git operations for github.com configured to use https protocol.
✓ Token: *******************
```

---

## Basic Usage (After Authentication)

### **View Workflow Runs:**
```bash
# List all workflow runs
gh run list

# List runs for specific workflow
gh run list --workflow=complete_verification.yml

# Show last 10 runs
gh run list --limit=10
```

---

### **Watch Workflow in Real-Time:**
```bash
# Watch the latest run
gh run watch

# Watch specific run by ID
gh run watch 21906523514

# This shows:
# - Current status
# - Job progress
# - Updates as it runs
# - Final result
```

---

### **View Run Details:**
```bash
# View latest run
gh run view

# View specific run
gh run view 21906523514

# View with full job details
gh run view 21906523514 --log
```

---

### **Download Artifacts:**
```bash
# Download artifacts from latest run
gh run download

# Download from specific run
gh run download 21906523514

# Download specific artifact
gh run download 21906523514 --name verification-certificate-automated
```

---

### **Re-run Failed Workflows:**
```bash
# Re-run failed jobs
gh run rerun 21906523514 --failed

# Re-run all jobs
gh run rerun 21906523514
```

---

## Comparison: With vs Without GitHub CLI

```
┌──────────────────────────────┬──────────────┬────────────────┐
│ Feature                      │ Without CLI  │ With CLI       │
├──────────────────────────────┼──────────────┼────────────────┤
│ Fix workflow                 │ ✅ Yes       │ ✅ Yes         │
│ Push to GitHub               │ ✅ Yes       │ ✅ Yes         │
│ Trigger workflow             │ ✅ Yes       │ ✅ Yes         │
│ Open browser to Actions      │ ✅ Yes       │ ✅ Yes         │
│ View in terminal             │ ❌ No        │ ✅ Yes         │
│ Watch real-time              │ ❌ No        │ ✅ Yes         │
│ Download artifacts CLI       │ ❌ No        │ ✅ Yes         │
│ Re-run from terminal         │ ❌ No        │ ✅ Yes         │
│ Advanced monitoring          │ ❌ No        │ ✅ Yes         │
└──────────────────────────────┴──────────────┴────────────────┘
```

---

## Which Script Should You Use?

### **Use basic script (NO GitHub CLI needed):**
```bash
chmod +x auto_fix_github_actions.sh
./auto_fix_github_actions.sh
```

**When:**
- ✅ You just want to fix and run
- ✅ You don't need terminal monitoring
- ✅ Browser viewing is fine
- ✅ First time user
- ✅ Quick fix needed

---

### **Use enhanced script (Requires GitHub CLI):**
```bash
chmod +x auto_fix_github_actions_enhanced.sh
./auto_fix_github_actions_enhanced.sh
```

**When:**
- ✅ You want real-time monitoring in terminal
- ✅ You need to download artifacts via CLI
- ✅ You prefer command-line tools
- ✅ You're a power user
- ✅ You already have GitHub CLI

---

## Quick Decision Guide

```
Do you have GitHub CLI installed?
├─ NO → Use basic script (auto_fix_github_actions.sh)
│        Works perfectly without GitHub CLI!
│
└─ YES → Use enhanced script (auto_fix_github_actions_enhanced.sh)
         Get extra monitoring features!
```

---

## Installation Commands Summary

**macOS:**
```bash
brew install gh
gh auth login
```

**Ubuntu/Debian:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
gh auth login
```

**Windows:**
```powershell
winget install --id GitHub.cli
gh auth login
```

---

## Testing GitHub CLI

After installation and authentication:

```bash
# Test basic functionality
gh --version

# Test authentication
gh auth status

# Test repo access
gh repo view jagg-ix/catept-verification

# Test workflow listing
gh run list --repo jagg-ix/catept-verification
```

---

## Troubleshooting

### **Problem: gh: command not found**
```bash
# Solution: Install GitHub CLI (see installation section above)
```

### **Problem: authentication required**
```bash
# Solution: Authenticate
gh auth login
```

### **Problem: failed to run git**
```bash
# Solution: Make sure you're in a git repository
cd ~/path/to/catept-verification
```

### **Problem: API rate limit exceeded**
```bash
# Solution: Authenticate to get higher rate limits
gh auth login
```

---

## Alternative: Use Basic Script (No Installation Needed)

**If you don't want to install GitHub CLI:**

```bash
# Just use the basic script
chmod +x auto_fix_github_actions.sh
./auto_fix_github_actions.sh

# It will:
# ✅ Fix the workflow
# ✅ Push to GitHub
# ✅ Open browser
# ✅ Show you the Actions URL

# No GitHub CLI needed!
```

---

## Recommendation

### **For most users:**
**Use the BASIC script** - it does everything you need without requiring GitHub CLI installation.

```bash
./auto_fix_github_actions.sh
```

### **For power users who want terminal monitoring:**
**Install GitHub CLI, then use the ENHANCED script**.

```bash
# Install
brew install gh  # macOS
# or
sudo apt install gh  # Ubuntu

# Authenticate
gh auth login

# Use enhanced script
./auto_fix_github_actions_enhanced.sh
```

---

## Bottom Line

### **GitHub CLI is 100% OPTIONAL**

✅ **Basic script works perfectly WITHOUT GitHub CLI**
✅ **Enhanced script adds convenience FOR power users**
✅ **Both scripts fix the workflow and trigger GitHub Actions**
✅ **Both scripts give you real, verifiable logs**

**Choose based on your preference, not necessity!**

---

## Quick Start (No GitHub CLI)

```bash
# Download and run basic script
chmod +x auto_fix_github_actions.sh
./auto_fix_github_actions.sh

# That's it! No GitHub CLI needed.
# Workflow will run and you'll get public logs!
```

---

**Links:**
- GitHub CLI: https://cli.github.com
- Installation: https://github.com/cli/cli#installation
- Documentation: https://cli.github.com/manual/
