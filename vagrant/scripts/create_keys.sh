 #!/bin/bash

DIR=$1 

if test $DIR
then
	ssh-keygen -N '' -q -f $DIR/key
fi
