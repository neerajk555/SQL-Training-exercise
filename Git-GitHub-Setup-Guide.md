# Git & GitHub Setup Guide for Windows

## Complete Step-by-Step Guide for Students

This guide will help you install Git, configure GitHub, and push your EY Training files to GitHub.

---

## Part 1: Install Git on Windows

### Step 1: Download Git
1. Open your web browser and go to: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. The download should start automatically (64-bit version for most modern PCs)
3. Wait for the installer to download (Git-2.x.x-64-bit.exe)

### Step 2: Install Git
1. Double-click the downloaded installer file
2. Click "Yes" if Windows asks for permission
3. Follow these settings during installation:
   - **Select Destination Location**: Keep default (C:\Program Files\Git) → Click "Next"
   - **Select Components**: Keep all defaults checked → Click "Next"
   - **Select Start Menu Folder**: Keep default → Click "Next"
   - **Choose default editor**: Select "Use Visual Studio Code as Git's default editor" (or your preferred editor) → Click "Next"
   - **Adjust PATH environment**: Select "Git from the command line and also from 3rd-party software" → Click "Next"
   - **Choose HTTPS transport backend**: Keep "Use the OpenSSL library" → Click "Next"
   - **Configure line ending conversions**: Keep "Checkout Windows-style, commit Unix-style line endings" → Click "Next"
   - **Configure terminal emulator**: Keep "Use MinTTY" → Click "Next"
   - **Choose default behavior of git pull**: Keep "Default (fast-forward or merge)" → Click "Next"
   - **Choose credential helper**: Keep "Git Credential Manager" → Click "Next"
   - **Configure extra options**: Keep defaults → Click "Next"
   - **Configure experimental options**: Leave unchecked → Click "Install"
4. Wait for installation to complete
5. Click "Finish"

### Step 3: Verify Git Installation
1. Press `Win + R` keys together
2. Type `cmd` and press Enter
3. In the Command Prompt, type:
   ```bash
   git --version
   ```
4. You should see output like: `git version 2.x.x.windows.x`
5. If you see the version number, Git is successfully installed!

---

## Part 2: Create a GitHub Account (Skip if you already have one)

### Step 1: Sign Up for GitHub
1. Go to: [https://github.com](https://github.com)
2. Click "Sign up" in the top-right corner
3. Enter your email address → Click "Continue"
4. Create a strong password → Click "Continue"
5. Choose a username (this will be public) → Click "Continue"
6. Type 'y' for product updates or 'n' to skip → Click "Continue"
7. Complete the verification puzzle
8. Check your email for the verification code
9. Enter the 6-digit code from your email
10. Answer the personalization questions (or skip)
11. Choose "Free" plan
12. Your GitHub account is now created!

---

## Part 3: Configure Git with Your GitHub Account

### Step 1: Configure Your Name and Email
1. Open Command Prompt (Win + R, type `cmd`, press Enter)
2. Set your name (replace with your actual name):
   ```bash
   git config --global user.name "Your Full Name"
   ```
   Example:
   ```bash
   git config --global user.name "John Smith"
   ```

3. Set your email (use the same email as your GitHub account):
   ```bash
   git config --global user.email "your.email@example.com"
   ```
   Example:
   ```bash
   git config --global user.email "john.smith@example.com"
   ```

### Step 2: Verify Configuration
1. Check your configuration:
   ```bash
   git config --global --list
   ```
2. You should see your name and email listed

### Step 3: Set Default Branch Name
1. Set the default branch name to 'main':
   ```bash
   git config --global init.defaultBranch main
   ```

---

## Part 4: Install GitHub CLI

### Step 1: Download GitHub CLI
1. Go to: [https://cli.github.com](https://cli.github.com)
2. Click "Download for Windows"
3. Download the MSI installer (gh_x.x.x_windows_amd64.msi)

### Step 2: Install GitHub CLI
1. Double-click the downloaded MSI file
2. Click "Next" on the welcome screen
3. Accept the license agreement → Click "Next"
4. Keep the default installation folder → Click "Next"
5. Click "Install"
6. Click "Yes" if Windows asks for permission
7. Wait for installation to complete
8. Click "Finish"

### Step 3: Verify GitHub CLI Installation
1. **Close and reopen** Command Prompt (important!)
2. Type:
   ```bash
   gh --version
   ```
3. You should see output like: `gh version x.x.x (yyyy-mm-dd)`

---

## Part 5: Authenticate GitHub CLI with Your Account

### Step 1: Login to GitHub via CLI
1. In Command Prompt, type:
   ```bash
   gh auth login
   ```

2. **What account do you want to log into?**
   - Use arrow keys to select: `GitHub.com`
   - Press Enter

3. **What is your preferred protocol for Git operations?**
   - Select: `HTTPS`
   - Press Enter

4. **Authenticate Git with your GitHub credentials?**
   - Type: `Y`
   - Press Enter

5. **How would you like to authenticate GitHub CLI?**
   - Select: `Login with a web browser`
   - Press Enter

6. **Copy the one-time code** shown in the terminal (e.g., A1B2-C3D4)

7. Press Enter to open GitHub in your browser

8. If browser doesn't open automatically:
   - Copy the URL shown in terminal
   - Paste it in your browser
   - Go to the link

9. In the browser:
   - Paste the one-time code
   - Click "Continue"
   - Click "Authorize github"
   - Enter your GitHub password if prompted

10. You should see: "Congratulations, you're all set!"

11. Return to Command Prompt - you should see: "✓ Authentication complete"

### Step 2: Verify Authentication
1. Test GitHub CLI:
   ```bash
   gh auth status
   ```
2. You should see your GitHub username and "Logged in to github.com"

---

## Part 6: Initialize Your Local Repository

### Step 1: Navigate to Your EY Training Folder
1. In Command Prompt, navigate to your folder:
   ```bash
   cd C:\path\to\ey training
   ```
   
   **Example paths:**
   - If it's on Desktop:
     ```bash
     cd C:\Users\YourUsername\Desktop\ey training
     ```
   - If it's in Documents:
     ```bash
     cd C:\Users\YourUsername\Documents\ey training
     ```
   
   **Tip:** You can also:
   - Open File Explorer
   - Navigate to your "ey training" folder
   - Click in the address bar and copy the path
   - Then use: `cd` followed by paste the path

### Step 2: Initialize Git Repository
1. Check if your folder already has Git initialized:
   ```bash
   git status
   ```
   
2. If you see "fatal: not a git repository", initialize Git:
   ```bash
   git init
   ```
   
3. You should see: "Initialized empty Git repository"

### Step 3: Add All Files to Git
1. Add all your screenshot images and files:
   ```bash
   git add .
   ```
   
   The `.` means "add all files in this folder"

2. Verify files are staged:
   ```bash
   git status
   ```
   
   You should see your files listed in green under "Changes to be committed"

### Step 4: Create Your First Commit
1. Commit the files with a message:
   ```bash
   git commit -m "Initial commit: Add screenshot images"
   ```
   
2. You should see a summary of files added

---

## Part 7: Create a New Repository on GitHub

### Step 1: Create Repository Using GitHub CLI
1. Create a new repository (choose a name without spaces):
   ```bash
   gh repo create ey-training-screenshots --public --source=. --remote=origin
   ```
   
   **Explanation:**
   - `ey-training-screenshots` = your repository name (change if you want)
   - `--public` = makes the repo public (use `--private` for private)
   - `--source=.` = uses current folder
   - `--remote=origin` = sets up the remote connection

2. When asked "Would you like to push commits from the current branch to 'origin'?":
   - Type: `y`
   - Press Enter

3. Your repository is now created and files are being pushed!

### Step 2: Verify Repository Creation
1. Check your GitHub repository:
   ```bash
   gh repo view --web
   ```
   
2. This will open your new repository in your web browser
3. You should see all your screenshot images uploaded!

---

## Part 8: Alternative Method - Create Repository on GitHub Website

### If you prefer to create the repository manually:

### Step 1: Create Repository on GitHub.com
1. Go to [https://github.com](https://github.com)
2. Log in to your account
3. Click the "+" icon in top-right corner
4. Select "New repository"
5. Fill in the details:
   - **Repository name**: `ey-training-screenshots` (no spaces)
   - **Description**: "Screenshots from EY Training" (optional)
   - **Public** or **Private**: Choose based on your preference
   - **DO NOT** check "Initialize this repository with a README"
   - **DO NOT** add .gitignore or license yet
6. Click "Create repository"

### Step 2: Link Local Repository to GitHub
1. Copy the HTTPS URL from GitHub (it looks like: `https://github.com/yourusername/ey-training-screenshots.git`)

2. In Command Prompt (in your ey training folder), add the remote:
   ```bash
   git remote add origin https://github.com/yourusername/ey-training-screenshots.git
   ```
   
   **Replace `yourusername` with your actual GitHub username!**

3. Verify remote is added:
   ```bash
   git remote -v
   ```

### Step 3: Push Your Files to GitHub
1. Push your files:
   ```bash
   git push -u origin main
   ```
   
2. If prompted for credentials, GitHub will open a browser window
3. Authorize the connection
4. Wait for the upload to complete
5. You should see: "Branch 'main' set up to track remote branch 'main' from 'origin'"

---

## Part 9: Push New Files When You Add Them

### Every Time You Add New Screenshots or Files:

### Step 1: Check What Changed
1. Navigate to your repository folder (if not already there):
   ```bash
   cd C:\path\to\ey training
   ```

2. Check the status:
   ```bash
   git status
   ```
   
   You'll see new files listed in red under "Untracked files"

### Step 2: Add New Files
1. Add all new files:
   ```bash
   git add .
   ```
   
   **Or** add specific files:
   ```bash
   git add screenshot1.png screenshot2.png
   ```

### Step 3: Commit the Changes
1. Commit with a descriptive message:
   ```bash
   git commit -m "Add new screenshots for Module 5"
   ```
   
   **Use descriptive messages like:**
   - `git commit -m "Add database diagram screenshots"`
   - `git commit -m "Add query results from exercise 3"`
   - `git commit -m "Add final project screenshots"`

### Step 4: Push to GitHub
1. Push the changes:
   ```bash
   git push
   ```
   
   or
   
   ```bash
   git push origin main
   ```

2. Wait for upload to complete
3. You should see: "Branch 'main' -> 'main'"

### Quick Command Summary (for regular updates):
```bash
git add .
git commit -m "Your descriptive message here"
git push
```

---

## Part 10: Verify Your Changes on GitHub

### Check Your Repository Online:
1. Go to your repository on GitHub:
   ```bash
   gh repo view --web
   ```
   
   or visit: `https://github.com/yourusername/ey-training-screenshots`

2. You should see:
   - All your files listed
   - The commit message you wrote
   - The timestamp of when you pushed

---

## Common Commands Reference

### Check Status
```bash
git status
```
Shows which files are changed, staged, or untracked

### View Commit History
```bash
git log
```
Shows all previous commits (press 'q' to exit)

### View Commit History (Short)
```bash
git log --oneline
```
Shows commits in one line each

### See What Changed in Files
```bash
git diff
```
Shows what changed in your files before staging

### Remove a File from Staging
```bash
git restore --staged filename.png
```
Unstages a file (if you added it by mistake)

### View Remote Repository
```bash
git remote -v
```
Shows the GitHub repository URL

---

## Troubleshooting

### Problem: "git: command not found" or not recognized
**Solution:**
1. Close and reopen Command Prompt
2. If still not working, restart your computer
3. Verify installation: `git --version`

### Problem: "gh: command not found" or not recognized
**Solution:**
1. Close and reopen Command Prompt (important!)
2. If still not working, restart your computer
3. Verify installation: `gh --version`

### Problem: Permission denied when pushing
**Solution:**
1. Re-authenticate with GitHub:
   ```bash
   gh auth login
   ```
2. Follow the authentication steps again

### Problem: "failed to push some refs"
**Solution:**
1. Pull the latest changes first:
   ```bash
   git pull origin main
   ```
2. Then push again:
   ```bash
   git push origin main
   ```

### Problem: "Updates were rejected because the remote contains work"
**Solution:**
```bash
git pull origin main --rebase
git push origin main
```

### Problem: Accidentally committed wrong files
**Solution:**
1. Undo last commit (keeps files):
   ```bash
   git reset --soft HEAD~1
   ```
2. Unstage files: `git restore --staged .`
3. Add only the files you want
4. Commit again

### Problem: Need to change last commit message
**Solution:**
```bash
git commit --amend -m "New commit message"
git push --force
```
**Warning:** Only do this if you haven't shared the commit yet!

---

## Best Practices

### 1. Commit Often
- Make small, frequent commits
- Each commit should represent one logical change
- Example: "Add Module 3 screenshots" not "Add all screenshots"

### 2. Write Clear Commit Messages
**Good messages:**
- "Add SQL query screenshots for joins exercise"
- "Update database schema diagram"
- "Add output screenshots for aggregate functions"

**Bad messages:**
- "update"
- "changes"
- "stuff"

### 3. Pull Before You Push
If working on multiple computers:
```bash
git pull
# Make your changes
git add .
git commit -m "Your message"
git push
```

### 4. Check Status Regularly
```bash
git status
```
Use this to see what's changed before committing

### 5. Review Before Committing
```bash
git diff
```
Check what you're about to commit

---

## Quick Workflow Checklist

### Initial Setup (One Time Only):
- [ ] Install Git
- [ ] Install GitHub CLI
- [ ] Configure Git with name and email
- [ ] Authenticate GitHub CLI
- [ ] Initialize local repository
- [ ] Create GitHub repository
- [ ] Push initial files

### Daily Workflow (Every Time You Add Files):
1. [ ] Save your new screenshots in the "ey training" folder
2. [ ] Open Command Prompt
3. [ ] Navigate to folder: `cd C:\path\to\ey training`
4. [ ] Check status: `git status`
5. [ ] Add files: `git add .`
6. [ ] Commit: `git commit -m "Descriptive message"`
7. [ ] Push: `git push`
8. [ ] Verify on GitHub: `gh repo view --web`

---

## Need Help?

### GitHub Documentation
- Git Basics: [https://git-scm.com/doc](https://git-scm.com/doc)
- GitHub CLI: [https://cli.github.com/manual](https://cli.github.com/manual)
- GitHub Guides: [https://guides.github.com](https://guides.github.com)

### Contact Your Instructor
If you encounter issues, reach out with:
1. Screenshot of the error message
2. The command you ran
3. The folder you're working in

---

## Summary

You've learned how to:
- ✅ Install and configure Git
- ✅ Set up GitHub account
- ✅ Install and configure GitHub CLI
- ✅ Initialize a local repository
- ✅ Create a GitHub repository
- ✅ Push your files to GitHub
- ✅ Update and push new files regularly

**Remember:** The basic workflow is simple:
1. Make changes/add files
2. `git add .`
3. `git commit -m "message"`
4. `git push`

