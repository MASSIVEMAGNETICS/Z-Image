# Linux System Optimization Guide for Intel i5-7200U + 16GB RAM + Intel HD Graphics 620

## Hardware Specifications
- **Processor**: Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz (2.70 GHz boost)
- **RAM**: 16.0 GB (15.9 GB usable)
- **Storage**: 238 GB SSD SAMSUNG SSD PM871b M.2 2280 256GB
- **Graphics**: Intel(R) HD Graphics 620 (128 MB)

## CPU Optimization

### 1. Install and Configure CPU Frequency Governor
```bash
# Install cpufreq utilities
sudo apt install cpufrequtils linux-tools-generic

# Set performance governor
sudo cpupower frequency-set -g performance

# To make it persistent, add to /etc/rc.local or create systemd service
echo 'performance' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### 2. Kernel Parameters for Performance
Add these to `/etc/default/grub` in the GRUB_CMDLINE_LINUX_DEFAULT line:
```
intel_pstate=enable i915.enable_fbc=1 pcie_aspm=force splash
```

Then update GRUB:
```bash
sudo update-grub
```

### 3. Process Priority Optimization
```bash
# Install and configure nice/renice settings
sudo apt install sysctl

# Add performance-related sysctl settings to /etc/sysctl.conf:
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
echo 'kernel.sched_migration_cost_ns=5000000' | sudo tee -a /etc/sysctl.conf
```

## Memory (RAM) Optimization

### 1. Optimize Swappiness
```bash
# Set swappiness to 10% (good for systems with lots of RAM and SSD)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 2. RAM Cache Optimization
```bash
# Reduce cache pressure (keep more things in cache)
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Storage Optimization (SSD)

### 1. Enable TRIM Support
```bash
# Enable periodic TRIM
sudo systemctl enable fstrim.timer

# Or enable continuous TRIM (for supported SSDs)
# Add 'discard' option to mount options in /etc/fstab
```

### 2. Mount Options for SSD
Edit `/etc/fstab` and add these options for your SSD partitions:
```
noatime,discard
```

### 3. I/O Scheduler Optimization
```bash
# Check current scheduler
cat /sys/block/sda/queue/scheduler

# Set deadline or noop scheduler for SSD
echo 'deadline' | sudo tee /sys/block/sda/queue/scheduler

# Make it persistent by adding to /etc/rc.local:
echo 'echo deadline | tee /sys/block/*/queue/scheduler' | sudo tee -a /etc/rc.local
```

## Graphics Optimization (Intel HD Graphics 620)

### 1. Install Intel Graphics Drivers
```bash
# For Ubuntu/Debian
sudo apt install intel-media-va-driver i965-va-driver mesa-vulkan-drivers

# For newer systems, also install
sudo apt install intel-media-va-driver-shaders intel-gpu-tools
```

### 2. Create Intel Graphics Configuration
Create `/etc/X11/xorg.conf.d/20-intel.conf`:
```
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
    Option "DRI" "3"
    Option "AccelMethod" "sna"
EndSection
```

## System-Wide Optimizations

### 1. Install Preload (Predictive Loading)
```bash
sudo apt install preload
# Preload learns your usage patterns and preloads frequently used programs
```

### 2. Optimize Desktop Environment
- Use lightweight desktop environment like XFCE or LXDE if performance is critical
- Disable visual effects and animations
- Use compton or picom for efficient compositing if needed

### 3. System Services Optimization
```bash
# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable cups  # if you don't print
sudo systemctl disable ModemManager

# Check services using the most memory
systemctl list-units --type=service --state=running | while read unit; do
    echo $unit
    sudo systemctl status $unit
done
```

## Boot Optimization

### 1. Reduce Boot Time
```bash
# Check boot time breakdown
systemd-analyze blame
systemd-analyze critical-chain

# Disable unnecessary boot services
sudo systemctl disable [service-name]
```

### 2. Kernel Boot Parameters
Add to GRUB configuration for faster boot:
```
quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 vt.color=1
```

## Performance Monitoring Tools

### 1. Install Performance Tools
```bash
sudo apt install htop iotop iostat iftop nethogs ncdu lm-sensors
sudo apt install intel-gpu-tools powertop
```

### 2. Use Performance Tools
```bash
# Monitor CPU usage
htop

# Monitor disk I/O
iotop

# Monitor GPU usage (Intel)
sudo intel_gpu_top

# Check temperatures
sensors

# Analyze power consumption
sudo powertop
```

## Advanced Optimizations

### 1. CPU Frequency Scaling
```bash
# Check available frequencies
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_frequencies

# Set min/max frequencies
echo 2500000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
echo 3200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

### 2. Thermal Management
```bash
# Install thermald for thermal management
sudo apt install thermald
sudo systemctl enable thermald
sudo systemctl start thermald
```

### 3. Process Lasso Equivalent for Linux
Consider using tools like:
- `cpulimit` to limit CPU usage of specific processes
- `nice` and `renice` for process priority
- `cgroups` for resource allocation

## Gaming Optimization (For Linux Gamers)

### 1. Install Mesa Drivers
```bash
sudo apt install mesa-utils mesa-common-dev
```

### 2. Use Optimus (for dual graphics)
```bash
# Install Bumblebee or PRIME depending on your system
sudo apt install bumblebee-nvidia primus
```

### 3. Steam Optimization
- Enable Steam's performance settings
- Use Proton for Windows games
- Set launch options for games: `-novid -nojoy -nosteamcontroller`

## Maintenance Commands

### 1. Regular Maintenance
```bash
# Clean package cache
sudo apt autoremove && sudo apt autoclean

# Clean temporary files
sudo rm -rf /tmp/*

# Update locate database
sudo updatedb
```

### 2. Performance Testing
```bash
# CPU benchmark
sudo apt install lmbench
lmbench-config

# Memory benchmark
sudo apt install mbw
mbw 1024

# Disk benchmark
sudo apt install bonnie++ hdparm
sudo hdparm -Tt /dev/sda
```

## Additional Configuration Files

### 1. Create a Performance Profile
Create `/etc/profile.d/performance.sh`:
```bash
#!/bin/bash
# Performance optimization settings

# Set CPU governor to performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null

# Optimize file handles
ulimit -n 65536
```

### 2. Cron Jobs for Maintenance
Add to crontab (`sudo crontab -e`) for regular maintenance:
```
# Weekly TRIM
0 2 * * 0 fstrim -v / 2>&1 | logger -t fstrim

# Daily cleaning of temporary files
0 3 * * * find /tmp -type f -atime +7 -delete
```

This guide provides comprehensive optimization strategies for your Intel i5-7200U system running Linux, maximizing performance while maintaining stability.