#!bash
###
### created: 2019-Aug-16  S.A. Birl  https://github.com/sbirl/random_oneko
### updated: 2019-Sep-13
###
### oneko --help  --or-- man oneko
###
### GNU: shuf -i 1-100 -n 1
### BSD:  jot -r 1 1-100
###
RNG="shuf -n 1 -i"
#RNG="jot -r 1"
###
###
### Logging
LOG="/tmp/oneko"
###
PATH=$PATH:/usr/games

declare -a Characters 		# Array of Character details
declare -a Names 		# Array of Character names


Usage()
{
	echo "Usage: $0 [1-9]"
	exit 0
}
#ENDS Usage()



PickCharacter()
{
	### I left out -tora
	NUM=`$RNG 0-3`
	echo "	NUM=$NUM  [0-3]" 				>> $LOG
	if   [ 0 -eq $NUM ]
	then
		CHAR="neko"
	elif [ 1 -eq $NUM ]
	then
		CHAR="dog"
	elif [ 2 -eq $NUM ]
	then
		CHAR="sakura"
	elif [ 3 -eq $NUM ]
	then
		CHAR="tomoyo"
	fi
	echo "		CHAR is $CHAR" 				>> $LOG
	CHAR="-${CHAR}"
}
#ENDS PickCharacter()



PickFGColor()
{
	NUM=`$RNG 0-6`
	if   [ 0 -eq $NUM ]
	then
		FG="black"
	elif [ 1 -eq $NUM ]
	then
		FG="red"
	elif [ 2 -eq $NUM ]
	then
		FG="green"
	elif [ 3 -eq $NUM ]
	then
		FG="orange"
	elif [ 4 -eq $NUM ]
	then
		FG="blue"
	elif [ 5 -eq $NUM ]
	then
		FG="purple"
	elif [ 6 -eq $NUM ]
	then
		FG="white"
	fi
	echo "	NUM=$NUM  [0-6]" 				>> $LOG
	echo "		FG is $FG" 				>> $LOG
}
#ENDS PickFGColor()

### I know that you can pass HTML-style colors (ie: #FF0000)
### for both foreground/background, but I wanted to keep the colors
### simple to limit annoying color clashes.

PickBGColor()
{
	BG=$FG
	while [ "$BG" == "$FG" ]
	do
		NUM=`$RNG 0-6`
	if   [ 0 -eq $NUM ]
	then
		BG="black"
	elif [ 1 -eq $NUM ]
	then
		BG="red"
	elif [ 2 -eq $NUM ]
	then
		BG="green"
	elif [ 3 -eq $NUM ]
	then
		BG="orange"
	elif [ 4 -eq $NUM ]
	then
		BG="blue"
	elif [ 5 -eq $NUM ]
	then
		BG="purple"
	elif [ 6 -eq $NUM ]
	then
		BG="white"
	fi
	done
	echo "	NUM=$NUM  [0-6]" 				>> $LOG
	echo "		BG is $BG" 				>> $LOG
}
#ENDS PickBGColor()



PickFocus()
{
	### If -tofocus, character runs along top
	### of active window to follow mouse.
	### Otherwise, character runs all over
	### the screen chasing the mouse.

	if   [ 1 -eq $LeaderM ]
	then
		echo "	LeaderM position filled. NUM=1" 	>> $LOG
		NUM=1
	elif [ 1 -eq $LeaderW ]
	then
		echo "	LeaderW position filled. NUM=0" 	>> $LOG
		NUM=0
	else
		NUM=`$RNG 0-1`
	fi


	echo "	NUM=$NUM  [0-1]" 				>> $LOG

	if   [ 1 -eq $NUM ]
	then
		LeaderW=1
		WINDOW="-tofocus "
		echo "		Window leader." 		>> $LOG
	elif [ 0 -eq $NUM ]
	then
		LeaderM=1
		echo "		Mouse leader." 			>> $LOG
	fi
	echo "	LeaderM=$LeaderM" 				>> $LOG
	echo "	LeaderW=$LeaderW" 				>> $LOG
}
#ENDS PickFocus()



PickIdle()
{
	### The man page describes  -idle  as "the threshold of
	### the speed which ''mouse'' running away to wake cat up."
	### But is that in pixels?  pixels per second?  I dunno.
	###
	### I know a smaller idle value results in the leaders
	### reacting to mouse movement MUCH faster than I like.
	### I tried a value of 1000, but that resulted in very
	### little movement, so I stayed with a value in the low
	### one-hundreds for the leader(s).
	### When idle=100 sometimes I can carefully move my mouse
	### across the entire screen without alerting the leaders.
	###
	### But I like the idea of giving each character their own
	### idle value so that they dont all react at once.
	IdleMin=0
	IdleMax=110
	if   [ $# -eq 1 ]
	then
		IdleMax=$1
	elif [ $# -eq 2 ]
	then
		IdleMin=$1
		IdleMax=$2
	fi

	IDLE=`$RNG ${IdleMin}-${IdleMax}`
	echo "	IDLE=$IDLE  [${IdleMin}-${IdleMax}]" 		>> $LOG
}
#ENDS PickIdle()



PickLeader()
{
	### I was going to have a follower choose a random character
	### but then I ran into 2+ followers choosing the same
	### character and sitting on top of each other.
	###
	### (Hmmm, maybe if I used  -position  as well ...)
#	NUM=`$RNG 1-$((COUNT -1))`
#	FOLLOW="${Names[$NUM]}"

	### I changed it so that a follower just runs after the
	### character that was created before it.
	FOLLOW="${Names[$(($COUNT -1))]}"
}
#ENDS PickLeader()



if [ $# -ne 1 ]
then
	Usage
fi

One=$1

Acceptable='^[1-9]$'
if ! [[ $One =~ $Acceptable ]]
then
	echo "'$One' is not a number between 1 and 9."
	Usage
fi


### We pick up to 9 instances to execute too many characters
### clutter the screen and it's hard to work with.
MAX=`$RNG 1-$One`
#MAX=$One


### Cant have too many leaders running around; they characters have
### a tendency to run over top of each over.  So pick 1 leader to
### follow the mouse, and 1 to run along the top of the window.
### Then the followers can chase after the leaders.
LeaderW=0
LeaderM=0


echo "Number of instances: $MAX"			 	> $LOG
COUNT=1

while [ $COUNT -le $MAX ]
do
	echo "=== Character $COUNT of $MAX ==========" 		>> $LOG

	### Character #1 is always a leader because
	### it has no one to follow.
	if   [ 1 -eq $COUNT ]
	then
		echo "	COUNT=1; Forced Leader"			>> $LOG
		NUM=1
	elif [ $LeaderW -eq 1 ] && [ $LeaderM -eq 1 ]
	then
		echo "	Leader positions filled; Forced 0." 	>> $LOG
		NUM=0
	else
		echo "	LeaderM=$LeaderM" 			>> $LOG
		echo "	LeaderW=$LeaderW" 			>> $LOG
		NUM=`$RNG 0-1`
	fi

	FG=""
	BG=""
	WINDOW=""
	FOLLOW=""

	if [ $NUM -eq 1 ]
	then
		echo "Leader" 					>> $LOG
		PickCharacter
		PickFGColor
		PickBGColor
		PickFocus
		PickIdle 100 110
		Characters[$COUNT]="-name 'oneko${COUNT}' $CHAR -fg $FG -bg $BG ${WINDOW}-idle $IDLE " >> $LOG

	else
		echo "Follower" 				>> $LOG
		PickCharacter
		PickFGColor
		PickBGColor
		PickLeader
		PickIdle 0 30
		Characters[$COUNT]="-name 'oneko${COUNT}' $CHAR -fg $FG -bg $BG -toname '$FOLLOW' -idle $IDLE " >> $LOG
	fi
	Names[$COUNT]="oneko${COUNT}"


	echo							>> $LOG
	echo "onkeo ${Characters[$COUNT]}" 			>> $LOG
	oneko ${Characters[$COUNT]} &
	echo							>> $LOG

	COUNT=$(($COUNT + 1))
done
echo "less $LOG"

###
#EOF
