#!/bin/bash

echo 'chkStatus.sh start'


# 0. delete all python cmd 
APPNAME=ajoah_chatbot
APP_DIR=/var/etc/MyData
REVISION=$(expr substr $(git rev-parse HEAD) 1 7)

docker build --tag $APPNAME:$REVISION .
docker stop $APPNAME
docker rm $APPNAME
docker run -it --name $APPNAME -p 80:80 $APPNAME:$REVISION


# chk src
while [ 0 = 0 ]
do 
    # 1. Get server data for update
    git fetch

    # 2. Get Heads each client & server 
    myHEAD=`/usr/bin/git rev-parse HEAD`
    serHEAD=`/usr/bin/git rev-parse @{u}`

    # 3. log HEADs
    echo "$myHEAD"
    echo "$serHEAD"

    # 4. if client is not latest version, pull server version 
    if [ $myHEAD = $serHEAD ] 
    then
        echo "  HEAD Latest [$myHEAD]"
    else
        echo "  myHEAD [$myHEAD] \n serHEAD [$serHEAD]"
        # 5. rebuild 
        git pull
        REVISION=$(expr substr $(git rev-parse HEAD) 1 7)

        docker build --tag $APPNAME:$REVISION .
        docker stop $APPNAME
        docker rm $APPNAME
        docker run -it --name $APPNAME -p 80:80 $APPNAME:$REVISION 
    fi
    
    sleep 5
done

