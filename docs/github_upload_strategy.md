# GitHub Push Guide

This guide covers two things: (1) pushing the complete project folder to GitHub for the first time, and (2) the commit plan to follow afterward if you want a clean, logical commit history instead of one giant upload.

---

## Part 1 — First-Time Full Folder Push

### Step 1: Create the repository on GitHub

1. Go to [github.com/new](https://github.com/new).
2. Repository name: `VLSI-Digital-Clock-Alarm`
3. Description: `Verilog/FPGA digital clock with programmable alarm — full RTL-to-bitstream flow on Xilinx Artix-7 (Basys3), with a self-checking testbench and verified post-implementation timing.`
4. Visibility: **Public** (so it shows on your profile).
5. **Do NOT** check "Add a README file", "Add .gitignore", or "Choose a license" — you already have these locally. Adding them on GitHub will create conflicts when you push.
6. Click **Create repository**. Keep the page open — it will show you the remote URL you need in Step 3.

### Step 2: Open a terminal in your project folder

```bash
cd path/to/VLSI-Digital-Clock-Alarm
```

(Replace `path/to/` with wherever the folder actually lives on your machine — e.g. `D:/Links/op/VLSI-Digital-Clock-Alarm` based on your Vivado screenshots.)

### Step 3: Initialize git and make the first commit

```bash
git init
git add .
git commit -m "Initial commit: complete VLSI digital clock with alarm project"
```

### Step 4: Connect to your GitHub repository and push

```bash
git branch -M main
git remote add origin https://github.com/YOUR USERNAME/VLSI-Digital-Clock-Alarm.git
git push -u origin main
```

If you're prompted for credentials and password login doesn't work (GitHub disabled password auth for git operations), you'll need a Personal Access Token instead of your account password — generate one at **GitHub → Settings → Developer settings → Personal access tokens**, and paste it in place of the password when prompted.

### Step 5: Verify

Refresh your GitHub repository page in the browser. You should see all folders (`rtl/`, `tb/`, `constraints/`, `simulation/`, `waveforms/`, `reports/`, `docs/`, `images/`) and the README rendered on the main page.

---

## Part 2 — Commit Plan (for future changes)

Once the initial push is done, don't keep doing one giant commit per change. Use small, descriptive commits so your git history itself shows engineering process — this is something people genuinely check when they look at a student's GitHub.

### General workflow for any future change

```bash
git add <specific files you changed>
git commit -m "Short, clear description of what changed and why"
git push
```

### Suggested commit sequence if you want to rebuild history from scratch instead of one big initial commit

If you'd rather have a more granular history than a single "Initial commit," stage and commit in this order instead of `git add .` all at once:

```bash
# 1. RTL modules
git add rtl/
git commit -m "Add clock_divider, counters, alarm_comparator, display RTL modules"

# 2. Top-level integration
git add rtl/digital_clock_alarm_top.v
git commit -m "Add top-level integration module"

# 3. Testbenches
git add tb/
git commit -m "Add self-checking testbench and waveform demo testbench"

# 4. Constraints
git add constraints/
git commit -m "Add Basys3 XDC constraints with full pin mapping"

# 5. Simulation proof
git add simulation/ waveforms/
git commit -m "Add simulation log (17/17 passing) and demo waveform"

# 6. Documentation
git add docs/ reports/
git commit -m "Add concepts, simulation/FPGA guides, project report, interview prep"

# 7. Screenshots
git add images/
git commit -m "Add synthesis and implementation screenshots (post-synthesis and post-route)"

# 8. README last (so it can reference everything above)
git add README.md .gitignore
git commit -m "Add README and gitignore"

# Push everything
git push -u origin main
```

### Commits for ongoing/future updates (examples)

Use this style going forward whenever you add or fix something:

```bash
git add constraints/basys3_constraints.xdc
git commit -m "Fix bitstream DRC error: allow unconstrained debug-only output pins"
git push

git add reports/project_report.md README.md
git commit -m "Update report with real post-implementation timing/utilization/power numbers"
git push

git add images/
git commit -m "Add post-implementation timing, utilization, power, and schematic screenshots"
git push
```

### Checking status before committing

Always check what's about to be committed before you commit it:

```bash
git status
```

This shows you which files are staged, modified, or untracked — useful to avoid accidentally committing something you didn't mean to (like a stray Vivado-generated file that should be in `.gitignore` instead).

### Useful follow-up commands

```bash
git log --oneline          # see your commit history, one line per commit
git diff                   # see what changed in tracked files before staging
git remote -v              # confirm which GitHub repo you're connected to
```

---

## Common Issues

**"fatal: remote origin already exists"** — you already ran `git remote add origin` once. Either skip that line, or fix the URL with:
```bash
git remote set-url origin https://github.com/seshu-8/VLSI-Digital-Clock-Alarm.git
```

**"Updates were rejected because the remote contains work that you do not have locally"** — this happens if you checked "Add a README" on GitHub during creation (Step 1) despite the instruction not to. Fix it with:
```bash
git pull origin main --allow-unrelated-histories
```
then resolve any conflict in README.md if prompted, and push again.

**Large file warnings** — your `.gitignore` already excludes large/raw `.vcd` waveform dumps and Vivado build folders, so you shouldn't hit this. If you do see a warning about a large file, check `git status` and make sure you're not accidentally adding a Vivado `.runs/` or `.cache/` folder that should have been ignored.