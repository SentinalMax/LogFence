#!/bin/bash

echo "Whats the name of your MySQL database?"
read DATABASE_NAME
FILENAME="outputFile.csv"

MYSQL_QUERY_1="SHOW VARIABLES LIKE \"secure_file_priv\""
SECURE_FILE_PATH_RAW=$(sudo mysql -uroot -D $DATABASE_NAME -e "$MYSQL_QUERY_1")

PSEUDO_OUTPUT_FILE=$(echo $SECURE_FILE_PATH_RAW | awk '{print $4}')
OUTPUT_FILE=$PSEUDO_OUTPUT_FILE"$FILENAME"
echo $OUTPUT_FILE

MYSQL_QUERY_2="TABLE wp_wfhits INTO OUTFILE '$OUTPUT_FILE' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '' LINES TERMINATED BY '\n'"

sudo mysql -uroot -D $DATABASE_NAME -e "$MYSQL_QUERY_2"