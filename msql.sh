#!/bin/bash

#root user id exit value is 0, if it has root access, else 1.
VALIDATE(){
        if [ $1 -ne 0 ]
        then
                echo "$2 Failed"
                exit 1
        else
                echo "$2 success"
        fi
}

LOGS_FOLDER="/var/log/"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
        echo "ERROR: you must have root access"
        exit 1
fi

echo "script started eecuting at: $TIMESTAMP" &>>$LOG_FILE_NAME

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? " Installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enablling mysqld"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysqld"

mysql -h mysql.aitha.online -uroot -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0 ]
then 
        mysql_secure_installation --set-root-pass ExpenseApp@1
        VALIDATE $? "Setting root password"
else
        echo " Password already set"
fi
#mysql -h aitha.online -u root -pExpenseApp@1 -e 'show databases;'