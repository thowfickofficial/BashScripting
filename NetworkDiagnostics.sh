#!/bin/bash

# Function to log messages to a file
log_message() {
  local message="$1"
  local log_file="network_diagnostics.log"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

# Function to perform network diagnostics
network_diagnostics() {
  # Prompt the user for the host to check
  read -p "Enter the host or IP address to check: " host

  # Prompt for the number of packets to send (default: 4)
  read -p "Enter the number of packets to send (default: 4): " num_packets
  num_packets=${num_packets:-4}

  # Prompt for the timeout in seconds (default: 1)
  read -p "Enter the timeout in seconds (default: 1): " timeout
  timeout=${timeout:-1}

  # Check if the host is reachable
  if ping -c $num_packets -W $timeout $host &> /dev/null; then
    log_message "Host $host is reachable."

    # Measure latency (ping time)
    latency=$(ping -c $num_packets -W $timeout $host | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    log_message "Latency to $host is $latency ms."

    # Prompt to perform DNS resolution
    read -p "Do you want to perform DNS resolution for $host? (y/n): " perform_dns_resolution
    if [ "$perform_dns_resolution" == "y" ] || [ "$perform_dns_resolution" == "Y" ]; then
      host_ip=$(host $host | awk '{print $4}')
      log_message "DNS resolution for $host: $host_ip"
    fi

    # Prompt to perform a port scan
    read -p "Do you want to perform a port scan on $host? (y/n): " perform_port_scan
    if [ "$perform_port_scan" == "y" ] || [ "$perform_port_scan" == "Y" ]; then
      read -p "Enter the port range to scan (e.g., 80-1000): " port_range
      log_message "Scanning ports $port_range on $host..."
      nmap -p $port_range $host 2>&1 | tee -a "$log_file"
    fi
  else
    log_message "Host $host is not reachable."
  fi
}

# Call the network diagnostics function
network_diagnostics
