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
#VALIDATE $? "user already exist"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "folder exist"
#VALIDATE $? "app foldr created"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "backend project download"

cd /app
VALIDATE $? "flder changed"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip "

cd /app
VALIDATE $? "fld chagned"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "npm installed"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATE $? "file copied"

#prepare mysql schma 

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "dnf installed"

mysql -h mysql.aitha.online -uroot -pExpenseApp@1 < /app/schema/backend.sql


systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "deamon-reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enable backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "start backend"



# systemctl restart backend