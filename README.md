# 🖥️ DevOps Bash Scripts – Linux Week Projects

This repository contains two powerful and interactive Bash scripts developed as part of my **DevOps Learning Journey** during **Linux Week**. These tools are designed for system administrators, DevOps engineers, and Linux enthusiasts who want to practice and apply real-world Bash scripting for log analysis and system monitoring.

---

## 📁 Scripts Included

### 1. 🔍 Log File Analyzer – `log_analyzer.sh`

A command-line utility to analyze log files and extract meaningful insights.

#### ✅ Features:
- Takes a log file path as an argument
- Counts the number of `ERROR`, `WARNING`, and `INFO` messages
- Displays top 5 most frequent error messages
- Shows first and last error timestamps
- Visualizes error frequency by hour (with ASCII bars)
- Generates a clean summary report saved to a timestamped `.txt` file

#### 📦 Usage:

` bash `  
` chmod +x log_analyzer.sh `

` ./log_analyzer.sh /path/to/logfile.log `


---------------------------------------------------------------------------------------------------
## 📊 Question 2: System Health Monitor Dashboard – `health_monitor.sh`

An interactive terminal-based **System Health Monitor** written in Bash. It displays live system resource statistics with visual indicators and logs alerts when thresholds are exceeded.

### ✅ Features

- ⏱️ Refreshes system stats every 3 seconds (customizable)
- 💻 Displays:
  - **CPU Usage** with top processes
  - **Memory Usage** (used, free, cache, buffers)
  - **Disk Usage** for mounted partitions
  - **Network Throughput** (download/upload speeds)
  - **Load Average**
- 🎨 Uses ASCII bars and ANSI colors:
  - 🟢 Green: Normal
  - 🟡 Yellow: Warning
  - 🔴 Red: Critical
- 🛎 Logs anomalies such as:
  - CPU usage above 80%
  - Memory usage above 75%
  - Disk usage above 75%
- 🎮 Keyboard Shortcuts:
  - `r`: Change refresh rate
  - `f`: Filter information (placeholder)
  - `q`: Quit
  - `h`: Help


