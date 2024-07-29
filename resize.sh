#! /bin/sh

read_with_delimiter()
{
	delim="$1"
	char=
	REPLY=

	while [ "$char" != "$delim" ]
	do
		char=$(dd bs=1 count=1 2>/dev/null) || return $?
		[ -z "$char" ] && return 1
		REPLY="${REPLY}${char}"
	done

	return 0
}

{

if ! tty >/dev/null
then
	return 1
fi

saved=$(stty -g)
trap 'stty "$saved" 2>/dev/null' EXIT

stty -echo -opost -isig -icanon min 0 time 10 2>/dev/null

printf '''[c'
res=0
read_with_delimiter c || res=$?

if [ $res -gt 0 ] || [ -z "$REPLY" ]
then
	stty "$saved" 2>/dev/null
	printf "not a VTxxx terminal?\n" >&2
	exit 2
fi

printf '''7''[r''[9999;9999H''[6n'
res=0
read_with_delimiter R || res=$?
printf '''8'

stty "$saved" 2>/dev/null
trap - EXIT

if [ $res -gt 0 ] || [ -z "$REPLY" ]
then
	printf "no size returned?\n" >&2
	exit 2
fi

# shellcheck disable=SC2046
set -- $( printf "%s" "$REPLY" | sed 's/^\[\([0-9]\+\);\([0-9]\+\)R.*$/matched \1 \2/' )
if [ $# != 3 ] || [ "$1" != matched ]
then
	printf "unable to parse size response!\n" >&2
	exit 2
fi

LINES=$2
COLUMNS=$3

stty rows "$LINES" cols "$COLUMNS"

} < /dev/tty > /dev/tty

printf "COLUMNS=%s;\n" "$COLUMNS"
printf "LINES=%s;\n" "$LINES"
printf "export COLUMNS LINES;\n"

exit 0
