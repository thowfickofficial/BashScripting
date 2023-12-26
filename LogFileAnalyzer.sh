#!/bin/bash

# Check if a log file path is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

log_file="$1"

# Check if the log file exists
if [ ! -f "$log_file" ]; then
    echo "Log file not found: $log_file"
    exit 1
fi

# Function to determine the log format
function determine_log_format() {
    if grep -q 'combined' "$log_file"; then
        echo "combined"
    elif grep -q 'common' "$log_file"; then
        echo "common"
    else
        echo "unknown"
    fi
}

log_format=$(determine_log_format)

# Function to geolocate IP addresses
function geolocate_ips() {
    if [ -f "GeoIP2-City.mmdb" ]; then
        while read -r line; do
            ip=$(echo "$line" | awk '{print $1}')
            location=$(geoiplookup -f GeoIP2-City.mmdb "$ip")
            echo "$line $location"
        done
    else
        echo "GeoIP2-City.mmdb database not found. Please download and place it in the script directory."
    fi
}

# Function to create a bar chart of URL access frequency
function create_url_chart() {
    data_file="url_access_data.dat"
    awk '{print $7}' "$log_file" | cut -d '?' -f 1 | sort | uniq -c | sort -nr > "$data_file"
    gnuplot -e "set title 'Most Accessed URLs'; set xlabel 'URL'; set ylabel 'Access Count'; set style data histogram; set style fill solid border -1; plot '$data_file' using 2:xtic(1) notitle"
    rm "$data_file"
}

# Main menu
while true; do
    clear
    echo "Log File Analyzer Menu"
    echo "1. Number of Unique IP Addresses"
    echo "2. Most Accessed URLs"
    echo "3. Geolocate IP Addresses"
    echo "4. Create URL Access Chart"
    echo "5. Quit"

    read -p "Select an option (1-5): " choice

    case $choice in
        1)
            awk '{print $1}' "$log_file" | sort -u | wc -l
            read -p "Press Enter to continue..."
            ;;
        2)
            create_url_chart
            read -p "Press Enter to continue..."
            ;;
        3)
            geolocate_ips
            read -p "Press Enter to continue..."
            ;;
        4)
            create_url_chart
            read -p "Press Enter to continue..."
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option (1-5)."
            read -p "Press Enter to continue..."
            ;;
    esac
done
