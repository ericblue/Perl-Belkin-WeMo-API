#!/bin/sh

# IP of switch or sensor
IP=$1
# Usually 49153 or 49142
PORT=$2
# {CMD}.xml file in the cwd
CMD=$3

if [ $# -ne 3 ]; then
    echo 1>&2 "Usage: $0 <IP> <PORT> <CMD>"
    exit 127
fi

if [ ! -f $CMD.xml ]
then
    echo "The $CMD.xml file doesn't exist"
    exit 127
fi

echo "Sending OFF request to [$IP:$PORT] ..."

POST -U -H 'SOAPACTION: "urn:Belkin:service:basicevent:1#SetBinaryState"' \
-c 'text/xml; charset="utf-8"' http://$IP:$PORT/upnp/control/basicevent1  \
< $CMD.xml

#curl -0 -A '' -v -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' \
#-H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" \
#--data @$CMD.xml http://$IP:$PORT/upnp/control/basicevent1 

