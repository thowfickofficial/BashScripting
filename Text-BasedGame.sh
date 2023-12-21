#!/bin/bash

# Function to display a message and wait for player input
function prompt {
  echo "$1"
  read -p "Press Enter to continue..."
}

# Function to handle player's death
function game_over {
  clear
  prompt "Game Over!"
  prompt "Your score: $score"
  prompt "Would you like to play again? (yes/no)"
  read play_again
  if [ "$play_again" == "yes" ]; then
    score=0
    inventory=()
    bash adventure_game.sh
    exit
  else
    clear
    prompt "Thanks for playing!"
    exit
  fi
}

# Initialize score and inventory
score=0
inventory=()

# Introduction
clear
prompt "Welcome to the Advanced Adventure Game!"
prompt "You find yourself standing at a crossroad."

# Choice 1
clear
prompt "You see a signpost. It points in two directions:"
prompt "1. Take the left path."
prompt "2. Take the right path."
read choice

if [ "$choice" == "1" ]; then
  # Choice 1, Left Path
  clear
  prompt "You chose the left path."
  prompt "You encounter a friendly gnome who gives you a map."
  prompt "The map reveals a treasure hidden nearby."
  prompt "Do you want to follow the map to find the treasure? (yes/no)"
  read treasure_choice
  
  if [ "$treasure_choice" == "yes" ]; then
    clear
    score=$((score + 10))
    inventory+=("Map")
    prompt "You follow the map and find a chest full of gold!"
    prompt "Your score: $score"
    prompt "You obtained a Map. It has been added to your inventory."
    prompt "Congratulations, you win!"
  else
    clear
    score=$((score - 5))
    prompt "You decide not to follow the map and continue on your journey."
    prompt "Unfortunately, you encounter a dragon and get eaten."
    game_over
  fi

else
  # Choice 2, Right Path
  clear
  prompt "You chose the right path."
  prompt "You come across a rickety bridge."
  prompt "1. Cross the bridge."
  prompt "2. Turn back and take the left path instead."
  read bridge_choice

  if [ "$bridge_choice" == "1" ]; then
    clear
    score=$((score + 15))
    prompt "You summon your courage and cross the bridge."
    prompt "On the other side, you find a hidden village of friendly people."
    inventory+=("Key")
    prompt "You decide to stay and live a happy life."
    prompt "Your score: $score"
    prompt "You obtained a Key. It has been added to your inventory."
    prompt "Congratulations, you win!"
  else
    clear
    score=$((score - 5))
    prompt "You turn back to take the left path."
    prompt "As you walk, you stumble into quicksand and get sucked in."
    game_over
  fi

fi

# Choice 3, Use Inventory
if [ ${#inventory[@]} -gt 0 ]; then
  clear
  prompt "You have items in your inventory:"
  for item in "${inventory[@]}"; do
    prompt "- $item"
  done
  prompt "You come across a locked door. Use an item from your inventory to unlock it."
  read use_item

  if [[ "${inventory[@]}" =~ "$use_item" ]]; then
    clear
    prompt "You use the $use_item to unlock the door."
    prompt "Behind the door, you discover a hidden treasure room!"
    score=$((score + 20))
    inventory+=("Treasure")
    prompt "You obtained a Treasure. It has been added to your inventory."
    prompt "Your score: $score"
    prompt "Congratulations, you win!"
  else
    clear
    prompt "You don't have that item in your inventory. Try another approach."
  fi
fi

# End of the game
prompt "Thanks for playing!"
prompt "Your final score: $score"
