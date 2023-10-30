#!/bin/bash

# Function to convert from Celsius to Fahrenheit
celsius_to_fahrenheit() {
  local celsius="$1"
  local fahrenheit=$(echo "scale=2; ($celsius * 9/5) + 32" | bc)
  echo "$celsius°C is equal to $fahrenheit°F"
}

# Function to convert from Fahrenheit to Celsius
fahrenheit_to_celsius() {
  local fahrenheit="$1"
  local celsius=$(echo "scale=2; ($fahrenheit - 32) * 5/9" | bc)
  echo "$fahrenheit°F is equal to $celsius°C"
}

# Function to convert from Celsius to Kelvin
celsius_to_kelvin() {
  local celsius="$1"
  local kelvin=$(echo "scale=2; $celsius + 273.15" | bc)
  echo "$celsius°C is equal to $kelvin K"
}

# Function to convert from Kelvin to Celsius
kelvin_to_celsius() {
  local kelvin="$1"
  local celsius=$(echo "scale=2; $kelvin - 273.15" | bc)
  echo "$kelvin K is equal to $celsius°C"
}

# Function to convert from Fahrenheit to Rankine
fahrenheit_to_rankine() {
  local fahrenheit="$1"
  local rankine=$(echo "scale=2; $fahrenheit + 459.67" | bc)
  echo "$fahrenheit°F is equal to $rankine°R"
}

# Function to convert from Rankine to Fahrenheit
rankine_to_fahrenheit() {
  local rankine="$1"
  local fahrenheit=$(echo "scale=2; $rankine - 459.67" | bc)
  echo "$rankine°R is equal to $fahrenheit°F"
}

# Function to display the menu
display_menu() {
  echo "Temperature Conversion Menu:"
  echo "1. Celsius to Fahrenheit"
  echo "2. Fahrenheit to Celsius"
  echo "3. Celsius to Kelvin"
  echo "4. Kelvin to Celsius"
  echo "5. Fahrenheit to Rankine"
  echo "6. Rankine to Fahrenheit"
}

# Check the number of arguments
if [ $# -ne 0 ]; then
  echo "Usage: $0"
  exit 1
fi

# Display the menu
display_menu

# Ask the user to select a conversion option
read -p "Select a conversion option (1-6): " option

# Perform the conversion based on the selected option
case "$option" in
  1)
    read -p "Enter temperature in Celsius: " celsius
    celsius_to_fahrenheit "$celsius"
    ;;
  2)
    read -p "Enter temperature in Fahrenheit: " fahrenheit
    fahrenheit_to_celsius "$fahrenheit"
    ;;
  3)
    read -p "Enter temperature in Celsius: " celsius
    celsius_to_kelvin "$celsius"
    ;;
  4)
    read -p "Enter temperature in Kelvin: " kelvin
    kelvin_to_celsius "$kelvin"
    ;;
  5)
    read -p "Enter temperature in Fahrenheit: " fahrenheit
    fahrenheit_to_rankine "$fahrenheit"
    ;;
  6)
    read -p "Enter temperature in Rankine: " rankine
    rankine_to_fahrenheit "$rankine"
    ;;
  *)
    echo "Invalid option. Please select a number between 1 and 6."
    exit 1
    ;;
esac
