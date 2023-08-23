# LogFence
> Wordfence attack log exporting tool.

## Installation
1. *awk/gawk are usually installed by default but please insure they are.*
2. ```git clone https://github.com/SentinalMax/LogFence.git```
3. ```cd LogFence```
4. ```chmod +x LogFence.sh```
5. ```bash LogFence.sh``` OR ```./LogFence.sh```

## Guide

- When first executing the program you will be prompted to enter your WordPress MySQL database name. *You can check this by navigating to* ```/var/www/html/wordpress/wp-config.php``` *and checking the **DB_NAME** line.*

- You'll then be prompted to input a name for the output file, because the program formats the file to **.csv** by default; please just write the name of the file *without an extension.*

- Usually the MySQL database containing information about your WordPress site will only be able to write to ```/var/lib/mysql-files/```. To insure this is the case you can type the following command: 
```
sudo mysql -uroot -D <DATABASE_NAME> -e 'SHOW VARIABLES LIKE "secure_file_priv"';
```

## Function

- This program was developed because I wanted to do some further analysis outside of the Wordfence plugin for wordpress. And I couldn't find any option to export attack logs from ***within*** Wordfence.

- If you're having any issues or have questions about this program you can reach me here: https://avergara.org/index.php/contact

