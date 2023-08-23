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
    echo "$OUTPUT_FILE exists." 
    exit
else
    MYSQL_QUERY_2="SELECT 'id','attackLogTime','ctime','ip','jsRun','statusCode','userID','newVisit','URL','referer','UA','action','actionDescription' UNION ALL SELECT id,attackLogTime,ctime,HEX(IP),jsRun,statusCode,userID,newVisit,URL,referer,UA,action,actionDescription FROM wp_wfhits INTO OUTFILE '$OUTPUT_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n'"
    sudo mysql -uroot -D $DATABASE_NAME -e "$MYSQL_QUERY_2"

    cd $PSEUDO_OUTPUT_FILE

    # Convert UNIX time to HR (Human Readable)

    # Convert Hexadecimals to IP addresses

    # Function to convert IPv4-mapped IPv6 string to IPv4
    convert_ip() {
        local hex_ip="$1"
        printf "%d.%d.%d.%d" \
            $(( 0x${hex_ip: -8:2} )) \
            $(( 0x${hex_ip: -6:2} )) \
            $(( 0x${hex_ip: -4:2} )) \
            $(( 0x${hex_ip: -2:2} ))
    }

    # Process the CSV file with awk
    awk -F',' -v OFS=',' '
    NR == 1 { print; next }  # Print header and skip to next line
    {
        ip_hex = substr($4, 2, length($4) - 2);  # Remove double quotes
        ip_dec = "'$(convert_ip $ip_hex)'";  # Call bash function for conversion
        $4 = "\"" ip_dec "\"";  # Replace the field
        print
    }' > $FILENAME



    echo "Output file stored: ${PWD}"
    #less $FILENAME
fi