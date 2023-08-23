#!/bin/bash

echo "Whats the name of your MySQL database:"
read DATABASE_NAME

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
    echo "$OUTPUT_FILE exists." 
    exit
else
    MYSQL_QUERY_2="SELECT 'id','attackLogTime','ctime','ip','jsRun','statusCode','userID','newVisit','URL','referer','UA','action','actionDescription' UNION ALL SELECT id,attackLogTime,ctime,HEX(IP),jsRun,statusCode,userID,newVisit,URL,referer,UA,action,actionDescription FROM wp_wfhits INTO OUTFILE '$OUTPUT_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n'"
    sudo mysql -uroot -D $DATABASE_NAME -e "$MYSQL_QUERY_2"

    cd $PSEUDO_OUTPUT_FILE

    # Convert UNIX time to HR (Human Readable) & Hexadecimals to IP addresses with awk
    MODIFIED_DATA=$(awk -F',' -v OFS=',' '
    NR == 1 { print; next }  # Print header and skip to next line
    {

        # Convert UNIX timestamps to human-readable format
        # ------------------------------------------------
        
        attackLogTime = substr($2, 2, length($2) - 2)  # Remove double quotes
        $2 = "\"" strftime("%Y-%m-%d %H:%M:%S", attackLogTime) "\""

        ctime = substr($3, 2, length($3) - 2)  # Remove double quotes
        $3 = "\"" strftime("%Y-%m-%d %H:%M:%S", ctime) "\""

        # IP Conversion
        # -------------

        ip_hex = substr($4, 2, length($4) - 2);  # Remove double quotes

        # Split the hexadecimal string to get the last 8 characters
        split(ip_hex, arr, "")
        last_8 = arr[length(arr)-7] arr[length(arr)-6] arr[length(arr)-5] arr[length(arr)-4] arr[length(arr)-3] arr[length(arr)-2] arr[length(arr)-1] arr[length(arr)]

        # Convert the last 8 characters of the hexadecimal string to decimal
        ip_dec = strtonum("0x" substr(last_8, 1, 2)) "." strtonum("0x" substr(last_8, 3, 2)) "." strtonum("0x" substr(last_8, 5, 2)) "." strtonum("0x" substr(last_8, 7, 2))

        $4 = "\"" ip_dec "\"";  # Replace the field
        print
    }' $FILENAME)

    # Overwrite the original file with the modified data
    echo "$MODIFIED_DATA" > $FILENAME

    echo "Output file stored: ${PWD}"

    echo "Would you like to transfer the file to another machine: y/n"
    read ANSWER_BOOL

    ANSWER_BOOL=$(echo "$ANSWER_BOOL" | tr '[:upper:]' '[:lower:]')

    if [[ "$ANSWER_BOOL" == "y" ]]
    then
        echo "yes"
    elif [[ "$ANSWER_BOOL" == "n" ]]
    then
        echo "no"
    fi
    #less $FILENAME
fi
