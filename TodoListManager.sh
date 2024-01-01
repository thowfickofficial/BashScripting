#!/bin/bash

# Define the file where the tasks will be stored
TODO_FILE="todo.txt"

# Define the file where completed tasks will be stored
COMPLETED_FILE="completed.txt"

# Define the format for due dates
DATE_FORMAT="%Y-%m-%d"

# Define colors for priority levels
COLOR_HIGH="\e[91m"  # Red
COLOR_MED="\e[93m"   # Yellow
COLOR_LOW="\e[92m"   # Green
COLOR_RESET="\e[0m"  # Reset color

# Check if the todo.txt file exists, and create it if not
if [ ! -e "$TODO_FILE" ]; then
    touch "$TODO_FILE"
fi

# Check if the completed.txt file exists, and create it if not
if [ ! -e "$COMPLETED_FILE" ]; then
    touch "$COMPLETED_FILE"
fi

# Function to display the usage of the script
usage() {
    echo "Todo List Manager"
    echo "Usage: $0 [add|list|done|remove|prioritize|sort|remind] [options]"
    echo "Options:"
    echo "  -t, --task          Task description"
    echo "  -c, --category      Task category"
    echo "  -d, --due           Due date (YYYY-MM-DD)"
    echo "  -p, --priority      Task priority (1-5)"
    echo "  -r, --reminder      Due date reminder (HH:MM on YYYY-MM-DD)"
    echo "  -D, --dependency    Task dependency (Task ID)"
    echo "  -P, --project       Project name"
    echo "  -h, --help          Show this help message"
    exit 1
}

# Function to validate and format due dates
validate_due_date() {
    local due_date="$1"
    if [[ ! "$due_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Invalid due date format. Use YYYY-MM-DD."
        exit 1
    fi
}

# Function to validate and format reminder times
validate_reminder_time() {
    local reminder_time="$1"
    if [[ ! "$reminder_time" =~ ^[0-9]{2}:[0-9]{2} ]]; then
        echo "Invalid reminder time format. Use HH:MM."
        exit 1
    fi
}

# Function to add a task to the list
add_task() {
    local task_description=""
    local category=""
    local due_date=""
    local priority=""
    local reminder_time=""
    local dependency=""
    local project=""

    echo -e "Add a new task:"
    read -p "Task description: " task_description

    while [ -z "$task_description" ]; do
        echo -e "${COLOR_HIGH}Task description is required.${COLOR_RESET}"
        read -p "Task description: " task_description
    done

    read -p "Category: " category
    read -p "Due Date (YYYY-MM-DD): " due_date
    read -p "Priority (1-5): " priority
    read -p "Reminder (HH:MM on YYYY-MM-DD): " reminder_time
    read -p "Dependency (Task ID): " dependency
    read -p "Project name: " project

    if [ -n "$due_date" ]; then
        validate_due_date "$due_date"
    fi

    if [ -n "$reminder_time" ]; then
        validate_reminder_time "$reminder_time"
    fi

    local task_id=$(date +%s) # Unique ID for the task

    echo "Task added with ID $task_id: $task_description"
    echo "Category: $category"
    [ -n "$due_date" ] && echo "Due Date: $due_date"
    [ -n "$priority" ] && echo "Priority: $priority"
    [ -n "$reminder_time" ] && echo "Reminder: $reminder_time on $due_date"
    [ -n "$dependency" ] && echo "Dependency on Task ID: $dependency"
    [ -n "$project" ] && echo "Project: $project"

    echo "$task_id | $task_description | $category | $due_date | $priority | $reminder_time | $dependency | $project" >> "$TODO_FILE"
}

# Function to list tasks
list_tasks() {
    if [ ! -s "$TODO_FILE" ]; then
        echo "No tasks found."
        return
    fi

    echo "Task List:"
    while IFS= read -r line; do
        task_id=$(echo "$line" | awk -F'|' '{print $1}')
        task_description=$(echo "$line" | awk -F'|' '{print $2}')
        category=$(echo "$line" | awk -F'|' '{print $3}')
        due_date=$(echo "$line" | awk -F'|' '{print $4}')
        priority=$(echo "$line" | awk -F'|' '{print $5}')
        reminder_time=$(echo "$line" | awk -F'|' '{print $6}')
        dependency=$(echo "$line" | awk -F'|' '{print $7}')
        project=$(echo "$line" | awk -F'|' '{print $8}')
        
        echo -e "Task ${COLOR_HIGH}$task_id${COLOR_RESET}: $task_description"
        [ -n "$category" ] && echo "  Category: $category"
        [ -n "$due_date" ] && echo -e "  Due Date: ${COLOR_MED}$due_date${COLOR_RESET}"
        [ -n "$priority" ] && echo -e "  Priority: ${COLOR_LOW}$priority${COLOR_RESET}"
        [ -n "$reminder_time" ] && echo -e "  Reminder: ${COLOR_LOW}$reminder_time on $due_date${COLOR_RESET}"
        [ -n "$dependency" ] && echo "  Dependency on Task ID: $dependency"
        [ -n "$project" ] && echo "  Project: $project"
        echo ""
    done < "$TODO_FILE"
}

# Function to mark a task as done
mark_done() {
    local task_id="$1"
    local task_line=$(grep -w "$task_id" "$TODO_FILE")
    if [ -n "$task_line" ]; then
        echo "$task_line" >> "$COMPLETED_FILE"
        sed -i "/$task_id/d" "$TODO_FILE"
        echo -e "Task ${COLOR_HIGH}$task_id${COLOR_RESET} marked as done."
    else
        echo -e "Task ${COLOR_HIGH}$task_id${COLOR_RESET} not found."
        exit 1
    fi
}

# Function to remove a task
remove_task() {
    local task_id="$1"
    local task_line=$(grep -w "$task_id" "$TODO_FILE")
    if [ -n "$task_line" ]; then
        sed -i "/$task_id/d" "$TODO_FILE"
        echo -e "Task ${COLOR_HIGH}$task_id${COLOR_RESET} removed."
    else
        echo -e "Task ${COLOR_HIGH}$task_id${COLOR_RESET} not found."
        exit 1
    fi
}

# Function to prioritize a task
prioritize_task() {
    local task_id="$1"
    local new_priority="$2"
    
    if [ -z "$new_priority" ]; then
        echo -e "${COLOR_HIGH}Please specify a new priority (1-5).${COLOR_RESET}"
        exit 1
    fi

    sed -i "/^$task_id/ s/| [0-9] |/| $new_priority |/" "$TODO_FILE"
    echo -e "Task ${COLOR_HIGH}$task_id${COLOR_RESET} prioritized to ${COLOR_LOW}$new_priority${COLOR_RESET}."
}

# Function to sort tasks
sort_tasks() {
    local sort_option="$1"
    case "$sort_option" in
        "due")
            sort -t'|' -k4 "$TODO_FILE" -o "$TODO_FILE"
            echo "Tasks sorted by due date."
            ;;
        "priority")
            sort -t'|' -k5 "$TODO_FILE" -o "$TODO_FILE"
            echo "Tasks sorted by priority."
            ;;
        *)
            echo -e "${COLOR_HIGH}Invalid sorting option. Use 'due' or 'priority'.${COLOR_RESET}"
            exit 1
            ;;
    esac
}

# Function to set a reminder for tasks with due dates
set_reminders() {
    local current_time=$(date "+%H:%M")
    local current_date=$(date "+$DATE_FORMAT")
    
    while IFS= read -r line; do
        task_id=$(echo "$line" | awk -F'|' '{print $1}')
        task_due_date=$(echo "$line" | awk -F'|' '{print $4}')
        reminder_time=$(echo "$line" | awk -F'|' '{print $6}')
        
        if [ -n "$reminder_time" ] && [ "$task_due_date" == "$current_date" ] && [ "$current_time" == "$reminder_time" ]; then
            task_description=$(echo "$line" | awk -F'|' '{print $2}')
            echo -e "Reminder: Task ${COLOR_HIGH}$task_id${COLOR_RESET} - $task_description is due now."
        fi
    done < "$TODO_FILE"
}

# Check for the correct number of arguments
if [ $# -lt 1 ]; then
    usage
fi

# Parse the command and execute the corresponding function
case "$1" in
    "add")
        shift
        add_task "$@"
        ;;
    "list")
        list_tasks
        ;;
    "done")
        mark_done "$2"
        ;;
    "remove")
        remove_task "$2"
        ;;
    "prioritize")
        prioritize_task "$2" "$3"
        ;;
    "sort")
        sort_tasks "$2"
        ;;
    "remind")
        set_reminders
        ;;
    *)
        usage
        ;;
esac
