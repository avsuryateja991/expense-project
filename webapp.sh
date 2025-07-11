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
mkdir -p $LOGS_FOLDER
echo "script started eecuting at: $TIMESTAMP" &>>$LOG_FILE_NAME

dnf install nginx -y  &>>$LOG_FILE_NAME
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "rmove path"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downlaod front end content"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "dir chagned"



unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unziped"

cp /root/expense-project/expense.conf /etc/nginx/default.d/


systemctl restart nginx

