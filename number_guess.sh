#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# User input
echo -e "Enter your username:"
read NAME
HAVE_NAME=$($PSQL "SELECT name FROM user_data WHERE name='$NAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_data WHERE name='$NAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE name='$NAME'")

# If the user exists
if [[ -z $HAVE_NAME ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_NAME=$($PSQL "INSERT INTO user_data(name, games_played, best_game) VALUES ('$NAME', 0, NULL);")
else 
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Guess the number
echo -e "\nGuess the secret number between 1 and 1000:"

RANDOM_NUMBER=$(( RANDOM  % 1000 + 1))
echo "$RANDOM_NUMBER"
read NUMBER
NUMBER_OF_GUESSES=1

while [ "$NUMBER" != $RANDOM_NUMBER ]
do
  if ! [[ $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ "$NUMBER" -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ "$NUMBER" -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
  read NUMBER
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
done

# insert tesults
if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE user_data SET best_game = $NUMBER_OF_GUESSES WHERE name='$NAME'")
fi

INSERT_GAME=$($PSQL "UPDATE user_data SET games_played = games_played + 1 WHERE name='$NAME'")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"