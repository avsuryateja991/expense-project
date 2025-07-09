#!/bin/bash

#root user id exit value is 0, if it has root access, else 1.

##FUNCTIONS##
VALIDATE(){
        if [ $1 -ne 0 ]
        then
                echo "$2 Failed"
                exit 1
        else
                echo "$2 success"
        fi
}
CHECKROOT(){
    USERID=$(id -u)
    if [ $USERID -ne 0 ]
    then
            echo "ERROR: you must have root access"
            exit 1
    fi
}


##VARIABLES##
LOGS_FOLDER="/var/log/"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

##SCRIPT$$
CHECKROOT
echo "script started eecuting at: $TIMESTAMP" &>>$LOG_FILE_NAME

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enable nodejs"


dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "install ndoejs"



useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "user added"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "app foldr created"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Download the application code to create ap"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip "

cd /app

npm install &>>$LOG_FILE_NAME
VALIDATE $? "unzip "

cp backend.service /etc/systemd/system/backend.service

systemctl daemon-reload

systemctl start backend

systemctl enable backend

dnf install mysql -y

mysql -h database.aitha.online -uroot -pExpenseApp@1 < /app/schema/backend.sql

systemctl restart backend