#!/bin/bash

userid=$(id -u)
packages=("mysql" "maven" "git" "nginx")
Logs_dir=/var/log/Shell_script
Logs_file="$Logs_dir/$0.log"
Timestamp=$(date)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# check whether user is root or not

if [ $userid -ne 0 ]; then
    echo -e "$R Please run this script with root user $N"
    exit 1
fi

#valiate function
VALIDATE(){
    if  [ $1 -eq 0 ]; then
        echo -e "$Timestamp [INFO] $2 ...... $G SUCCESS $N" | tee -a $Logs_file
    else
        echo -e "$Timestamp [ERROR] $2 ....... $R FAILED $N" | tee -a $Logs_file
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo.repo file"

dnf install mongodb-org -y 
VALIDATE $? "Installing mongodb-org"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "Starting mongodb service"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf
VALIDATE $? "Updating mongodb config file"

systemctl restart mongod
VALIDATE $? "Restarting mongodb service"