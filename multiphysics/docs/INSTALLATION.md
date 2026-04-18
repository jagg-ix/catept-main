# Installation Guide

Complete step-by-step guide for installing and setting up the Wolfram Verification Infrastructure.

---

## System Requirements

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Linux, macOS, or Windows |
| **RAM** | 2GB minimum, 4GB recommended |
| **Disk Space** | 50MB for infrastructure, 2GB for WolframEngine |
| **Network** | Required for WolframEngine download and activation |

### Software Requirements

**Required:**
- WolframScript (from WolframEngine or Mathematica)
- Bash shell (Linux/macOS) or equivalent (Windows)

**Optional:**
- Git (for version control)
- Python 3.8+ (for alternative demo)
- Text editor or IDE

---

## Installation Options

### Option 1: WolframEngine (Free for Developers) ⭐ Recommended

**Advantages:**
- ✅ Free for personal and development use
- ✅ Full Wolfram Language support
- ✅ Command-line execution
- ✅ Perfect for our scripts

**Installation Steps:**

#### Step 1: Download WolframEngine

Visit: https://www.wolfram.com/engine/

Click "Download Free" and select your platform:
- Linux
- macOS
- Windows

#### Step 2: Install

**Linux:**
```bash
# Download .sh installer
bash WolframEngine_13.X.X_LINUX.sh

# Follow prompts
# Default installation: /usr/local/Wolfram/WolframEngine/13.X
```

**macOS:**
```bash
# Download .dmg
# Double-click to mount
# Drag WolframEngine to Applications

# Or use Homebrew
brew install --cask wolfram-engine
```

**Windows:**
```powershell
# Download .exe installer
# Double-click and follow wizard
# Default: C:\Program Files\Wolfram Research\Wolfram Engine\13.X
```

#### Step 3: Activate License

```bash
# Run WolframScript for first time
wolframscript

# Follow activation prompts:
# 1. Enter Wolfram ID (create free at wolfram.com)
# 2. Confirm activation
# 3. Choose "Free Wolfram Engine for Developers"
```

#### Step 4: Verify Installation

```bash
# Check version
wolframscript --version
# Output: WolframScript 1.X.X for Wolfram Engine 13.X.X

# Test execution
wolframscript -code '2+2'
# Output: 4
```

**Troubleshooting:**
- If `wolframscript` not found, add to PATH:
  - Linux/macOS: Add to `~/.bashrc` or `~/.zshrc`
  - Windows: Add to System Environment Variables

---

### Option 2: Mathematica (If You Have a License)

**Advantages:**
- ✅ Full interactive environment
- ✅ Notebooks and visualization
- ✅ WolframScript included

**Installation:**

1. **Download from Wolfram website**
   - Visit: https://www.wolfram.com/mathematica/
   - Log in with your license
   - Download for your platform

2. **Install following platform-specific instructions**

3. **Activate license**
   - Launch Mathematica
   - Enter activation key
   - Complete activation

4. **Verify WolframScript**
   ```bash
   wolframscript --version
   ```

---

### Option 3: Wolfram Cloud (Limited Testing)

**Advantages:**
- ✅ No installation needed
- ✅ Web-based
- ✅ Free tier available

**Limitations:**
- ❌ Cannot run .wls scripts directly
- ❌ Limited computation in free tier
- ❌ Must copy/paste code

**Use Case:** Quick testing only, not recommended for full verification

---

## Installing the Verification Infrastructure

### Step 1: Obtain the Code

**Option A: From Repository**
```bash
git clone <repository-url>
cd CATEPT-Complete-v3.3/WolframVerification
```

**Option B: From Archive**
```bash
# Extract downloaded archive
unzip CATEPT-v3.3.zip
cd CATEPT-Complete-v3.3/WolframVerification
```

### Step 2: Verify Directory Structure

```bash
ls -la
# Should see:
# lib/
# proofs/
# scripts/
# tests/
# pipeline/
# README.md
# etc.
```

### Step 3: Test Installation

**Quick test:**
```bash
# Make pipeline executable (Linux/macOS)
chmod +x pipeline/run_all_verifications.sh

# Run single batch
wolframscript scripts/batch8_foundations.wls
```

**Expected output:**
```
========================================
BATCH 8: FOUNDATIONS
========================================

Running all Batch 8 tests...

✓ Eq22_ComplexAction - PASSED
...

========================================
SUMMARY: 20/20 tests PASSED
========================================
```

**If this works, installation is complete!** ✅

---

## Platform-Specific Instructions

### Linux

**Additional Tools:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install bash git

# Fedora/RHEL
sudo dnf install bash git

# Arch
sudo pacman -S bash git
```

**PATH Configuration:**
```bash
# Add to ~/.bashrc
export PATH="/usr/local/Wolfram/WolframEngine/13.X/Executables:$PATH"

# Reload
source ~/.bashrc
```

**Verification:**
```bash
which wolframscript
# Output: /usr/local/Wolfram/WolframEngine/13.X/Executables/wolframscript
```

---

### macOS

**Using Homebrew (Recommended):**
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install WolframEngine
brew install --cask wolfram-engine

# Verify
wolframscript --version
```

**Manual Installation:**
1. Download .dmg from Wolfram
2. Install to /Applications
3. Add to PATH in ~/.zshrc:
   ```bash
   export PATH="/Applications/Wolfram Engine.app/Contents/MacOS:$PATH"
   ```

**Permissions:**
```bash
# If needed, grant execution permissions
chmod +x pipeline/run_all_verifications.sh
```

---

### Windows

**PowerShell Setup:**
```powershell
# Verify WolframScript in PATH
wolframscript --version

# If not found, add to PATH:
# 1. Open System Properties → Environment Variables
# 2. Edit Path variable
# 3. Add: C:\Program Files\Wolfram Research\Wolfram Engine\13.X\
```

**Running Scripts:**

**Option A: PowerShell**
```powershell
cd WolframVerification
wolframscript scripts\batch8_foundations.wls
```

**Option B: WSL (Windows Subsystem for Linux)**
```bash
# Install WSL if needed
wsl --install

# Use Linux instructions within WSL
```

**Option C: Git Bash**
```bash
# Install Git for Windows (includes Git Bash)
# Use similar to Linux commands
```

---

## Troubleshooting Installation

### Issue: "wolframscript: command not found"

**Cause:** WolframScript not in PATH

**Solution:**
```bash
# Find WolframScript
find / -name wolframscript 2>/dev/null

# Add directory to PATH
export PATH="/path/to/wolfram/bin:$PATH"

# Make permanent (add to ~/.bashrc or ~/.zshrc)
```

---

### Issue: "License activation failed"

**Cause:** Network issues or invalid Wolfram ID

**Solutions:**
1. Check internet connection
2. Verify Wolfram ID at wolfram.com
3. Try activating again:
   ```bash
   wolframscript
   # Follow activation prompts
   ```
4. Contact Wolfram Support if persists

---

### Issue: "Permission denied"

**Cause:** Script not executable

**Solution:**
```bash
# Make executable
chmod +x pipeline/run_all_verifications.sh
chmod +x scripts/*.wls
chmod +x tests/*.wls
```

---

### Issue: "Cannot find library file"

**Cause:** Running from wrong directory

**Solution:**
```bash
# Always run from WolframVerification/ root
cd /path/to/WolframVerification
wolframscript scripts/batch8_foundations.wls
```

---

### Issue: Tests fail on fresh install

**Possible Causes:**

1. **WolframScript version incompatibility**
   - Verify version ≥ 13.0
   - Update if needed

2. **Missing dependencies**
   - Ensure all files present
   - Re-download if necessary

3. **Corrupted files**
   - Verify checksums
   - Re-download archive

**Debug Steps:**
```bash
# 1. Verify installation
wolframscript --version

# 2. Test basic functionality
wolframscript -code 'Print["Hello"]'

# 3. Check file integrity
ls -lh scripts/
ls -lh lib/
ls -lh tests/

# 4. Run minimal test
wolframscript -code 'Get["lib/ComplexActionLib.wl"]'
```

---

## Post-Installation Configuration

### Optional: Configure Output Directory

```bash
# Create custom output directory
mkdir -p /path/to/custom/outputs

# Create symlink
ln -s /path/to/custom/outputs outputs
```

### Optional: Set Up Git

```bash
cd WolframVerification

# Initialize (if not already)
git init

# Configure
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Track changes
git add .
git commit -m "Initial setup"
```

### Optional: IDE/Editor Setup

**VS Code:**
- Install Wolfram Language extension
- Configure Wolfram path in settings

**Emacs:**
- Install wolfram-mode
- Configure path to wolframscript

**Vim:**
- Install wolfram-language syntax
- Add to .vimrc

---

## Verification Checklist

After installation, verify:

- [ ] WolframScript installed and in PATH
- [ ] License activated successfully
- [ ] Can execute: `wolframscript --version`
- [ ] Can run basic code: `wolframscript -code '2+2'`
- [ ] Directory structure correct
- [ ] Scripts are executable
- [ ] Single batch runs successfully
- [ ] Tests pass

**If all checked, you're ready to use the system!** ✅

---

## Alternative: Python Demo (No Wolfram Needed)

If you cannot install Wolfram software, use the Python demo:

### Requirements
```bash
python3 --version  # Need 3.8+
pip3 install numpy scipy  # Install dependencies
```

### Run Demo
```bash
cd WolframVerification/demo
python3 python_verification_demo.py
```

**Output:**
```
10/10 tests passed (100.0%)
🎉 ALL TESTS PASSED! 🎉
```

This demonstrates the verification methodology works, even without Wolfram software.

---

## Getting Help

### Documentation
- Architecture: `subdocs/ARCHITECTURE.md`
- Usage: `subdocs/USAGE_GUIDE.md`
- Troubleshooting: `subdocs/TROUBLESHOOTING.md`

### Resources
- Wolfram Engine: https://www.wolfram.com/engine/
- Wolfram Documentation: https://reference.wolfram.com/
- Support Forum: https://community.wolfram.com/

### Common Links
- Download: https://www.wolfram.com/engine/
- Activation: https://account.wolfram.com/
- Documentation: https://reference.wolfram.com/language/

---

## Next Steps

After successful installation:

1. ✅ Read [Usage Guide](USAGE_GUIDE.md)
2. ✅ Review [Batch Details](BATCH_DETAILS.md)
3. ✅ Run full verification pipeline
4. ✅ Explore individual batches
5. ✅ Review scientific results

---

## Summary

**Quick Install (Linux/macOS):**
```bash
# 1. Install WolframEngine
wget <wolfram-engine-url>
bash WolframEngine_*.sh

# 2. Activate
wolframscript  # Follow prompts

# 3. Clone repository
git clone <repo-url>

# 4. Test
cd WolframVerification
wolframscript scripts/batch8_foundations.wls
```

**Quick Install (Windows):**
```powershell
# 1. Download and run WolframEngine installer
# 2. Activate through prompts
# 3. Extract verification infrastructure
# 4. Test
cd WolframVerification
wolframscript scripts\batch8_foundations.wls
```

**Installation complete!** 🎉

Ready to verify 192 equations across 10 thematic batches!
