#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -l <length>     Password length (default: 12)"
    echo "  -a              Include lowercase letters (default: yes)"
    echo "  -A              Include uppercase letters (default: yes)"
    echo "  -d              Include digits (default: yes)"
    echo "  -s              Include special characters (default: yes)"
    echo "  -x              Exclude ambiguous characters (like '1', 'l', 'O', '0')"
    echo "  -h              Display this help message"
    exit 1
}

# Default options
password_length=12
include_lowercase=true
include_uppercase=true
include_digits=true
include_special_chars=true
exclude_ambiguous=false

# Parse command line options
while getopts ":l:aAdsxh" opt; do
    case "$opt" in
        l)
            password_length="$OPTARG"
            ;;
        a)
            include_lowercase=true
            ;;
        A)
            include_uppercase=true
            ;;
        d)
            include_digits=true
            ;;
        s)
            include_special_chars=true
            ;;
        x)
            exclude_ambiguous=true
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# Function to generate a random password
generate_password() {
    local charset=""

    [ "$include_lowercase" = true ] && charset+="abcdefghijklmnopqrstuvwxyz"
    [ "$include_uppercase" = true ] && charset+="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    [ "$include_digits" = true ] && charset+="0123456789"
    [ "$include_special_chars" = true ] && charset+="!@#$%^&*()_+{}[]<>?/|"

    if [ "$exclude_ambiguous" = true ]; then
        charset=$(echo "$charset" | tr -d '1lIO0')
    fi

    if [ -z "$charset" ]; then
        echo "Error: Password must include at least one character type."
        exit 1
    fi

    local password
    password=$(tr -dc "$charset" < /dev/urandom | head -c "$password_length")
    echo "$password"
}

# Generate and print the password
random_password=$(generate_password)
echo "Random Password: $random_password"
