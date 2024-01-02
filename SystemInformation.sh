#!/bin/bash

# Function to check for CPU virtualization support
check_cpu_virtualization() {
  virtualization_support=$(egrep -o '(vmx|svm)' /proc/cpuinfo)
  if [ -n "$virtualization_support" ]; then
    echo "Virtualization Support: Yes"
  else
    echo "Virtualization Support: No"
  fi
  echo
}

# Function to display CPU information
display_cpu_info() {
  echo "===== CPU Information ====="
  lscpu
  check_cpu_virtualization
  echo
}

# Function to display Memory information
display_memory_info() {
  echo "===== Memory Information ====="
  free -h
  echo
}

# Function to display Disk usage information
display_disk_info() {
  echo "===== Disk Usage Information ====="
  df -h
  echo
}

# Function to display Network information
display_network_info() {
  echo "===== Network Information ====="
  ip addr
  echo
}

# Function to generate an HTML report
generate_html_report() {
  report_filename="system_info_report.html"
  {
    echo "<html>"
    echo "<head><title>System Information Report</title></head>"
    echo "<body>"
    echo "<h1>System Information Report</h1>"
    display_cpu_info
    display_memory_info
    display_disk_info
    display_network_info
    echo "</body>"
    echo "</html>"
  } > "$report_filename"
  echo "HTML report generated: $report_filename"
}

# Function to display usage information
display_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -c  Display CPU information"
  echo "  -m  Display Memory information"
  echo "  -d  Display Disk usage information"
  echo "  -n  Display Network information"
  echo "  -h  Display this help message"
  echo "  -o  Save the output to an HTML file"
  echo
  exit 1
}

# Main script
echo "System Information Script"

# Parse command-line options
while getopts ":cmdnoh" opt; do
  case $opt in
    c)
      display_cpu_info
      ;;
    m)
      display_memory_info
      ;;
    d)
      display_disk_info
      ;;
    n)
      display_network_info
      ;;
    o)
      generate_html_report
      ;;
    h)
      display_usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      display_usage
      ;;
  esac
done

# If no options are provided, display all information
if [ $OPTIND -eq 1 ]; then
  display_cpu_info
  display_memory_info
  display_disk_info
  display_network_info
fi
