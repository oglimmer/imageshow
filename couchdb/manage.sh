#!/bin/sh

set -e

COUCHDB_USER=admin
COUCHDB_PASSWORD=foobar

COUCHDB_HOST=localhost
COUCHDB_PORT=5984
COUCHDB_DB=oziwtsap
COUCHDB_PROTOCOL=http
COUCHDB_PIDFILE=couchdb.pid
COUCHDB_PARAMS="--silent --show-error --max-time 0.5"
COUCHDB_URL="$COUCHDB_PROTOCOL://$COUCHDB_USER:$COUCHDB_PASSWORD@$COUCHDB_HOST:$COUCHDB_PORT/$COUCHDB_DB"
#COUCHDB_URL="$COUCHDB_PROTOCOL://$COUCHDB_HOST:$COUCHDB_PORT/$COUCHDB_DB"

checkJsonResult() {
  if [[ $(echo "$2" | jq --exit-status '.ok' 2>/dev/null) != "true" ]];
  then
    echo $*
  fi
}

if [ "$1" == "start-docker" ];
then
  PID=$(docker run -d -p 5984:$COUCHDB_PORT -e COUCHDB_USER=$COUCHDB_USER -e COUCHDB_PASSWORD=$COUCHDB_PASSWORD couchdb:1.7)
  echo $PID>"$COUCHDB_PIDFILE"
fi
if [ "$1" == "stop-docker" ];
then
  PID=$(<"$COUCHDB_PIDFILE")
  docker stop $PID
  rm "$COUCHDB_PIDFILE"
fi
if [ "$1" == "logs-docker" ];
then
  PID=$(<"$COUCHDB_PIDFILE")
  docker logs $2 $PID
fi

if [ "$1" == "init-couchdb" ];
then
  checkJsonResult "Delete /$COUCHDB_DB" $(curl $COUCHDB_PARAMS -X DELETE "$COUCHDB_URL" 2>&1)
  checkJsonResult "Create /$COUCHDB_DB" $(curl $COUCHDB_PARAMS -X PUT "$COUCHDB_URL" 2>&1)
  checkJsonResult "Create users view" $(curl $COUCHDB_PARAMS -X PUT --data-binary @docs_view_users.js "$COUCHDB_URL/_design/users" 2>&1)
  checkJsonResult "Create pictures view" $(curl $COUCHDB_PARAMS -X PUT --data-binary @docs_view_pictures.js "$COUCHDB_URL/_design/pictures" 2>&1)
  checkJsonResult "Create picturegroups view" $(curl $COUCHDB_PARAMS -X PUT --data-binary @docs_view_picturegroups.js "$COUCHDB_URL/_design/picturegroups" 2>&1)
  
  checkJsonResult "Create obj user1" $(curl $COUCHDB_PARAMS -H "Content-Type: application/json" -X POST --data-binary @sample_obj_user1.js "$COUCHDB_URL/" 2>&1)
  checkJsonResult "Create obj user2" $(curl $COUCHDB_PARAMS -H "Content-Type: application/json" -X POST --data-binary @sample_obj_user2.js "$COUCHDB_URL/" 2>&1)
fi

if [ "$1" == "auto" ];
then
  #REST_API=http://localhost:3000/api
  REST_API=https://image.oglimmer.de/api
  access_token=$(curl -s -X POST -d "email=test@aol.com" -d "password=test" \
    -d "grant_type=password" -d "client_id=genuine-web-client" $REST_API/v1/auth/token \
    | jq -r ".access_token")
  picResult=$(curl -s -X POST --data-binary "@test.jpg" -H "x_grouprefname: test jpg" \
    -H "x_comment: this is just a test" -H "x_filename: test.jpg" -H "Content-Type: image/jpeg" \
    -H "Authorization: Bearer $access_token" $REST_API/v1/pictures)
  groupRef=$(echo $picResult|jq -r ".group_ref")
  picResult2=$(curl -s -X POST --data-binary "@test2.jpg" -H "x_groupref: $groupRef" \
    -H "x_comment: this is another test" -H "x_filename: test2.jpg" -H "Content-Type: image/jpeg" \
    -H "Authorization: Bearer $access_token" $REST_API/v1/pictures)
  echo "picturegroups:"
  curl -s -H "Authorization: Bearer $access_token" $REST_API/v1/picturegroups|jq
  echo "picuture URLs:"
  echo "$REST_API/v1/pictures/"$(echo $picResult|jq -r ".pictureUUID")
  echo "$REST_API/v1/pictures/"$(echo $picResult2|jq -r ".pictureUUID")
  echo "-H \"Authorization: Bearer $access_token\" $REST_API/v1/picturegroups/summary"
fi

#CREATE USER
#curl -X POST -d "email=mail@olikurt.de" -d "password=test" http://localhost:3000/api/v1/users/
#{ returnCode: 101 }

#LOGIN
#curl -X POST -d "email=mail@olikurt.de" -d "password=test" -d "grant_type=password" -d "client_id=genuine-web-client" http://localhost:3000/api/v1/auth/token
# { returnCode: 101 } or { access_token }

#GET ALL PICTUREGROUPS
#curl -H "Authorization: Bearer XXX" "http://localhost:3000/api/v1/picturegroups"
# []

#POST PICTURE
#curl -X POST --data-binary "@foo.file" -H "x_grouprefname: foobar2" -H "x_comment: foobar test blalal" -H "x_filename: foobar.txt" -H "Content-Type: image/jpeg" -H "Authorization: Bearer $access_token" "http://localhost:3000/api/v1/pictures"
# obj

#GET PIC
#curl "http://localhost:3000/api/v1/pictures/XXX"
# binary data
