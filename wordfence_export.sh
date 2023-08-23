#!/bin/bash

echo "Whats the name of your MySQL database:"
read DATABASE_NAME

#SELECT 'id','attackLogTime','ctime','ip','jsRun','statusCode','userID','newVisit','URL','referer','UA','action','actionDescription' UNION ALL SELECT id,attackLogTime,ctime,HEX(IP),jsRun,statusCode,userID,newVisit,URL,referer,UA,action,actionDescription FROM wp_wfhits INTO OUTFILE '/var/lib/mysql-files/test8.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

echo "Name the output file:"
read FILENAME

# Concat file ext '.csv' to file name
EXT=".csv"
FILENAME=$FILENAME"$EXT"

MYSQL_QUERY_1="SHOW VARIABLES LIKE \"secure_file_priv\""
SECURE_FILE_PATH_RAW=$(sudo mysql -uroot -D $DATABASE_NAME -e "$MYSQL_QUERY_1")

PSEUDO_OUTPUT_FILE=$(echo $SECURE_FILE_PATH_RAW | awk '{print $4}')
OUTPUT_FILE=$PSEUDO_OUTPUT_FILE"$FILENAME"

# Check if file already exists in path
if [[ -f "$OUTPUT_FILE" ]]; then
    echo "$OUTPUT_FILE exists." && exit
elif
    end
fi

#MYSQL_QUERY_2="TABLE wp_wfhits INTO OUTFILE '$OUTPUT_FILE' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '' LINES TERMINATED BY '\n'"
MYSQL_QUERY_2="SELECT 'id','attackLogTime','ctime','ip','jsRun','statusCode','userID','newVisit','URL','referer','UA','action','actionDescription' UNION ALL SELECT id,attackLogTime,ctime,HEX(IP),jsRun,statusCode,userID,newVisit,URL,referer,UA,action,actionDescription FROM wp_wfhits INTO OUTFILE '$OUTPUT_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n'"

sudo mysql -uroot -D $DATABASE_NAME -e "$MYSQL_QUERY_2"

cd $PSEUDO_OUTPUT_FILE
less $FILENAME