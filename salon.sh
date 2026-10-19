#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to my salon! How can I help you?"

# Show the services until a valid service is selected.
while true
do
  echo ""

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  while IFS="|" read  SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done <<< "$SERVICES"

  echo -e "\nEnter a service number:"
  read  SERVICE_ID_SELECTED

  # Only query the database if the input is a positive integer.
  if [[ $SERVICE_ID_SELECTED =~ ^[1-9][0-9]*$ ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -n $SERVICE_NAME ]]
    then
      break
    fi
  fi

  echo -e "\nI could not find that service. Please choose again."
done

echo -e "\nWhat's your phone number?"
read  CUSTOMER_PHONE

# Escape apostrophes before using input in SQL.
CUSTOMER_PHONE_SQL=${CUSTOMER_PHONE//\'/\'\'}

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL'")

if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read  CUSTOMER_NAME

  CUSTOMER_NAME_SQL=${CUSTOMER_NAME//\'/\'\'}

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE_SQL', '$CUSTOMER_NAME_SQL')")

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read  SERVICE_TIME

SERVICE_TIME_SQL=${SERVICE_TIME//\'/\'\'}

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."