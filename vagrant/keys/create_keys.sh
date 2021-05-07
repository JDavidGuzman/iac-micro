 #!/bin/bash

LOCATION=$1
COMMAND='ssh-keygen -N "" -q -f' 

if test $LOCATION
then
	FILE=$PWD/$LOCATION
	$COMMAND $FILE/key
else
	$COMMAND key
fi
