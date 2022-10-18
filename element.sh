#!/bin/bash

## Definitions
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

GET_ID() {
  ## check for argument
  # if no argument
  if [[ -z $1 ]]
  then
    # exit with error
    echo "Please provide an element as an argument."
    return
  fi

  ## process argument to get ID
  # attempt look up by atomic number if $1 is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ID="$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")"
    # if found
    if [[ ! -z $ID ]]
    then
      # get and print data
      OUTPUT_RESULT $ID
      return
    fi
  fi
  # attempt look up by symbol
  ID="$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")"
  # if found
  if [[ ! -z $ID ]]
  then
    # get and print data
    OUTPUT_RESULT $ID
    return
  fi
  # attempt look up by name
  ID="$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")"
  # if found
  if [[ ! -z $ID ]]
  then
    # get and print data
    OUTPUT_RESULT $ID
    return
  fi
  # if not found, exit with error
  echo "I could not find that element in the database."
}

OUTPUT_RESULT(){
  ## output info about the element
  # retrieve data
  RESULT="$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ID")"
  # remove excess spaces
  RESULT=$(echo $RESULT | sed -E 's/ +//g')
  # read variables
  IFS="|"
  read ID NAME SYMBOL TYPE MASS MELT BOIL <<< $RESULT
  IFS=" "
  # print results
  echo "The element with atomic number $ID is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
}

## start the script
GET_ID $1
