#!/bin/bash

usage() {
    echo "Usage: $0 [OPTIONS] <filename>"
    echo "OPTIONS:"
    echo "  -d <delimiter>   Count words based on a specific delimiter (default: space)"
    echo "  -s               Sort and display the most common words"
    echo "  -f               Display word frequency count"
    echo "  -e               Exclude common stop words"
    echo "  -o <outputfile>  Specify an output file for word frequency and common words"
    echo "  -h               Display this help message"
    exit 1
}

interactive_menu() {
    echo "Word Counting Script"
    echo "---------------------"
    read -p "Enter the filename: " filename

    if [ ! -f "$filename" ]; then
        echo "Error: File not found: $filename"
        exit 1
    fi

    read -p "Enter the word delimiter (default: space): " delimiter
    delimiter="${delimiter:- }"

    read -p "Sort and display the most common words (yes/no, default: yes): " sort_words_input
    case $sort_words_input in
        [Nn]*)
            sort_words=false
            ;;
        *)
            sort_words=true
            ;;
    esac

    read -p "Display word frequency count (yes/no, default: yes): " show_frequency_input
    case $show_frequency_input in
        [Nn]*)
            show_frequency=false
            ;;
        *)
            show_frequency=true
            ;;
    esac

    read -p "Exclude common stop words (yes/no, default: no): " exclude_stop_words_input
    case $exclude_stop_words_input in
        [Yy]*)
            exclude_stop_words=true
            ;;
        *)
            exclude_stop_words=false
            ;;
    esac

    read -p "Specify an output file for word frequency and common words (default: none): " output_file

    run_word_counter
}

run_word_counter() {
    # Count words, lines, and characters using wc
    lines=$(wc -l < "$filename")
    words=$(cat "$filename" | tr -s "$delimiter" '\n' | wc -w)
    characters=$(wc -m < "$filename")

    echo "File: $filename"
    echo "Lines: $lines"
    echo "Words: $words"
    echo "Characters: $characters"

    if [ "$show_frequency" = true ]; then
        if [ "$exclude_stop_words" = true ]; then
            content=$(remove_stop_words "$(cat "$filename")")
        else
            content=$(cat "$filename")
        fi

        word_count=$(echo "$content" | tr -s "$delimiter" '\n' | sort | uniq -c | sort -nr)
        echo "Word Frequency Count:"
        if [ -n "$output_file" ]; then
            echo "$word_count" > "$output_file"
            echo "Word frequency count saved to $output_file"
        else
            echo "$word_count"
        fi
    fi

    if [ "$sort_words" = true ]; then
        if [ "$exclude_stop_words" = true ]; then
            content=$(remove_stop_words "$(cat "$filename")")
        else
            content=$(cat "$filename")
        fi

        word_count=$(echo "$content" | tr -s "$delimiter" '\n' | sort | uniq -c | sort -nr)
        echo "Most Common Words:"
        if [ -n "$output_file" ]; then
            echo "$word_count" | head -n 10 > "$output_file"
            echo "Most common words saved to $output_file"
        else
            echo "$word_count" | head -n 10
        fi
    fi
}

remove_stop_words() {
    local stopwords=("the" "and" "in" "to" "of" "a" "for" "on" "with" "as" "by" "an" "at" "from")
    local text="$1"
    for word in "${stopwords[@]}"; do
        text=$(echo "$text" | sed -e "s/\b$word\b//g")
    done
    echo "$text"
}

# Check for interactive mode
if [ "$#" -eq 0 ]; then
    interactive_menu
else
    while getopts ":d:sfeo:h" opt; do
        case $opt in
            d)
                delimiter="$OPTARG"
                ;;
            s)
                sort_words=true
                ;;
            f)
                show_frequency=true
                ;;
            e)
                exclude_stop_words=true
                ;;
            o)
                output_file="$OPTARG"
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                usage
                ;;
        esac
    done

    shift $((OPTIND-1))
    filename="$1"

    if [ -z "$filename" ]; then
        echo "Error: You must provide a filename."
        usage
    fi

    run_word_counter
fi
