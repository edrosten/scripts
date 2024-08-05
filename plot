#!/bin/bash


#Process command line arguments

arg=
fatal=0
stdin=0
foreground=0

tmpfile="/tmp/plot-stdin-$USER-$$-$RANDOM$RANDOM.pipe"
tmpps="/tmp/plot-output-$USER-$$-$RANDOM$RANDOM"


prog="$(basename $0)"
xr="[*:*]"
yr="[*:*]"
extra=
fatal=0
defaultusing=
output_command_only=

defaulttype=line

linestyle=1

while :
do
	[ "${1:0:1}" != "-" ]  && break
	[ "$1" == "-" ] && break
	[ "$1" == "--" ] && break

	case "$1" in 
		-com)
			output_command_only=1
			;;
		-png)
			[ "x$terminal" != x ] && echo "Warning: $1 overrides specified terminal type." 1>&2
			terminal="set terminal png"
			foreground=1
			;;
		-psc)
			[ "x$terminal" != x ] && echo "Warning: $1 overrides specified terminal type." 1>&2
			terminal="set terminal postscript eps color solid"
			foreground=1
			;;
		-ps)
			[ "x$terminal" != x ] && echo "Warning: $1 overrides specified terminal type." 1>&2
			terminal="set terminal postscript eps"
			foreground=1
			;;
		-ps=*)
			[ "x$terminal" != x ] && echo "Warning: $1 overrides specified terminal type." 1>&2
			terminal="set terminal postscript ${1:4}"
			foreground=1
			;;
		-term)
			[ "x$terminal" != x ] && echo "Warning: $1 overrides specified terminal type." 1>&2
			terminal="set terminal $2"
			shift
			;;
		-fg)
			foreground=1
			;;
		-xr)
			xr="[$2]"
			shift
			;;
		-yr)
			yr="[$2]"
			shift
			;;
		-x2l)
			extra="${extra}; set x2label \"$2\""
			shift
			;;
		-y2l)
			extra="${extra}; set y2label \"$2\""
			shift
			;;
		-xl)
			extra="${extra}; set xlabel \"$2\""
			shift
			;;
		-yl)
			extra="${extra}; set ylabel \"$2\""
			shift
			;;
		-key|-k)
			tmp="${2}"
			shift

			case "$tmp" in
				1)   tmp="left bottom";;
				2)   tmp="b c";;
				3)   tmp="right bottom";;
				4)   tmp="l c";;
				5)   tmp="centre";;
				6)   tmp="r c";;
				7)   tmp="left top";;
				8)   tmp="top centre";;
				9)   tmp="right top";;
				1o)   tmp="left bottom outside";;
				2o)   tmp="bottom outside";;
				3o)   tmp="right bottom outside";;
				4o)   tmp="left outside";;
				6o)   tmp="right outside";;
				7o)   tmp="left top outside";;
				8o)   tmp="top outside";;
				9o)   tmp="right top outside";;
				off)  tmp="off";;
			esac
			extra="${extra}; set key $tmp"
			;;
		-logx)
			extra="${extra}; set logscale x 10"
			;;
		-logx=*)
			extra="${extra}; set logscale x ${1:6}"
			;;
		-logy)
			extra="${extra}; set logscale y 10"
			;;
		-logy=*)
			extra="${extra}; set logscale y ${1:6}"
			;;
		-t)
			extra="${extra}; set title \"$2\""
			shift
			;;
		-x)
			extra="${extra}; $2"
			shift
			;;
		-u)
			defaultusing="using $2"
			shift
		    ;;
		-w)
			defaulttype="$2"
			shift
		    ;;
		-e)
			defaulttype=errorbars
		    ;;
		-p)
			defaulttype=points
			;;
		-lp)
			defaulttype=linespoints
			;;
		-h)	
			cat << FOO
$prog: Plots input data in GNUplot. The output appears in a window

Options:

$prog [-h] [-xr range] [-yr range] [ -ps[=opts] | -psc | -term opts] [-x com]
      [-xl xlabel] [-yl ylabel] [-key spec] [-t title] [-logx[=base]]
	  [-logy[=base]] [-p] [-lp] [-fg]
      [--] [file1 [column_specification] [plot_modifier]] ...

-com         output the GNUPlot command string only
-ps[=opts]   output EPS on stdout instead of displaying in a window opts 
             specifies the PS options. Defaults are "eps color"
-psc         output color EPS on stdout
-term opts   specify output type (see "help terminal" in GNUPlot). Different
             terminal types display point types differently, so specified point
             types may not be correct.
-xr range    set x axis range to range (of the form start:end) see "help range"
-yr range    set y axis range
-xl xlabel   set X axis label
-yl ylabel   set Y axis label
-x2l xlabel  set X2 axis label
-y2l ylabel  set Y2 axis label

-key spec    if spec is a digit, then the position of the key is set according
			 to the position of the digit on the numeric pad (0 excluded).
			 Appending o to the digit causes the key to be placed outside the
			 plot. If spec is "off", the key is disabled.  Otherwise, the spec
			 is used directly.
-k spec      Synonym for -key spec

-logx[=base] make X axis logarithmic with given base (default 10)
-logy[=base] make Y axis logarithmic with given base (default 10)
-t title     set graph title
-x com	     add the extra GNUPLOT commands com. This can be repeated.

			 Specify the plot specification for lines, which applies if not
			 overridden by a modifier. The default is "line".
-p           Points
-lp          Linespoints
-e           Errorbars      
-w spec      Use spec as the default

-u a,b,...   Default columns to use when plotting data. Not applied to plot=

-fg          run in foreground
-h           this.
--           last command line option

If no filename is specified, the input comes from stdin. A filename of - is
takes input from stdin.

If the filename has the form plot=... then ... is inserted directly. This is
used to access gnuplot internal features, such as plotting functions. This can 
be used with modifiers, so extra spcifications such as "with line" will cause
errors.


Column Specification:
---------------------
This takes the form (col1,col2,...). Normally one or two columns will be 
specified.

Axes specification tkes the form -x1y1, -x1y2, etc

Plot modifiers:
---------------

--          Plot as lines
->          Plot vectors (requires 4 colums, x y dx dy)
|           Plot as impulses
@           Plot as points (let GNUPlot select the type)
.           Plot as dots
<>    <.>   Plot as diamonds, or with a centred dot
+           Plot as plusses
[]    [.]   Plot as squares, or with a centred dot
o     o.    Plot as circles, or with a centred dot
X           Plot as X's
^     ^.    Plot as upwards triangles, or with centred dot
v     v.    Plot as downwards triangles, or with centred dot
*           Plot as stars
E           Plot as errorbars
spec=SPEC   Plot as "with SPEC". Useful for advanced GNUPLot features.
--1         Plot as line style 1 also for 2, 3, etc...
--S         Plot as as line style N, incremented from 1 for each --S

Plot modifiers may have an optional title. This takes the form:
*,title     Where * is the plot modifier. The plot modifier may be absent
if the title is present.
An empty title removes the label completely.

All point forms (@, etc) can  be preceeded by -- (eg --@) to cause
the plot to be done with lines and points.


Examples:
---------

Plot file 'tmp':           plot tmp
Plot file tmp points       plot tmp @
Also, title it 'My data'   plot tmp @,'My data'
The default style          plot tmp ,'My data'
Now plot cols 1,2 and 1,3  plot tmp '(1,2)' @,'My data'  tmp '(1,3)' @,'Other data'

FOO
			exit 0
			;;

		*)
			echo "plot: Error: unknown command: $1" 1>&2
			fatal=1
			;;
			
	esac	
	shift

done

if [[ $terminal == "" ]]
then
	terminal="set terminal x11"
fi

if [ $fatal == 1 ]
then
	echo "Fatal errors occured. Use plot -h for help. " 1>&2
	exit 1
fi

nargs=$#

while :
do

	f="$1"
	title=""
	nonfile=

	if [ "$f" == "-" ] || [ $nargs == 0 ]
	then
		if [ $stdin != 0 ]
		then
			echo "Error: stdin can only be used once!"
			fatal=1
		fi

		stdin=1
		
		f="$tmpfile" 
		title="stdin"
	elif  echo "$f" | grep -q '^plot='
	then
		f="${f#plot=}"
		nonfile=1
	elif ! [ -e "$1" ]
	then
		echo "$prog: Error: file \"$1\" not found!"
		fatal=0	

	fi

	shift

	using="$defaultusing"
	axes=""

	while :
	do

		if echo "$1" | grep -q '^(.*)$'
		then
			using="using $(echo "$1" | sed -e's/^(//;s/)$//;')"
			shift
		elif echo "$1" | grep -q '^-x[12]y[12]$'
		then
			axes="axes ${1#-}"
			shift
		else
			break
		fi

	done

	type=$defaulttype
	mark="$1"
	#Parse the spec. It looks like:
	# [--]X[,title] or --[,title]
	spec="$1"
	
	manualspec=""
	#if echo "$spec" | egrep -q '^(((--)?([@.+X*]|([ov^]\.?)|(\[\.?\])|(<\.?>)))|(--))(,.*)?$'
	if echo "$spec" | egrep -q -e '^--(,.*)?$' \
	                           -e '--[0-9]+(,.*)?$'\
	                           -e '--S(,.*)?$'\
	                           -e '--E(,.*)?$'\
	                           -e '^(--)?->(,.*)?$'\
	                           -e '^(--)?\|(,.*)?$'\
	                           -e '^(--)?@(,.*)?$'\
	                           -e '^(--)?\.(,.*)?$'\
	                           -e '^(--)?<>(,.*)?$'\
	                           -e '^(--)?\+(,.*)?$'\
	                           -e '^(--)?\[\](,.*)?$'\
	                           -e '^(--)?o\.?(,.*)?$'\
	                           -e '^(--)?X(,.*)?$'\
	                           -e '^(--)?\^\.?(,.*)?$'\
	                           -e '^(--)?v\.(,.*)?$'\
	                           -e '^(--)?\*(,.*)?$'\
							   -e '^,.*$'
	then
		#it's a point specification
		if echo "$spec" | grep -q -e'^--'
		then
			type=linespoints
		elif [ "${spec:0:1}" == "," ]
		then
			type=$defaulttype
		else
			type=point
		fi
		
		#Extract the marker type
		mark="$(echo "$spec" | sed -e's/\(--\)\?\([^,]\{1,3\}\)\(,.*\)\?$/\2/')"


		#Extract the title if applicable
		if [ "$type" != "" ] && echo "$spec" | grep -q ,
		then
			title="$(echo "$spec" | sed -e's/[^,]*,\(.*\)/\1/')"
		fi
		shift
	elif echo "$spec"  | grep -q '^spec='
	then
		type="${spec#spec=}"
		title=""
		manualspec="$type"

		shift
	fi

	#type="`echo $type | sed -e 'y/PDLSXTA/0123456/'`"
	# 0 small dots
	# 1 plusses
	# 2 X
	# 3 star
	# 4 Box, dot
	# 5 filled box
	# 6 Circle, dot
	# 7 filled circle
	# 8 triangle ^, dot
	# 9 filled triangle ^
	#10 triangle \/ dot
	#11 filled  \/
	#12 Diamond dot
	#13 Filled diamond
	case "$mark" 
	in	
		"@")  	type="$type";;
		".")  	type="$type pt 0" ;;
		"+")  	type="$type pt 1";;
		"X")  	type="$type pt 2";;
		"*")  	type="$type pt 3";;
		"[.]") 	type="$type pt 4";;
		"[]") 	type="$type pt 5";;
		"o.") 	type="$type pt 6";;
		"o") 	type="$type pt 7";;
		"^.")  	type="$type pt 8";;
		"^")  	type="$type pt 9";;
		"v.")  	type="$type pt 10";;
		"v")  	type="$type pt 11";;
		"<.>") 	type="$type pt 12";;
		"<>") 	type="$type pt 13";;

		[1-9] | [1-9][0-9]) type="$type ls $mark";;
		S) type="$type ls $((linestyle++))";;

		
		"|")  	type="impulses";;
		"|,"*)  title="${1:2}" 
				type="impulses";;

		"--") 	type="line";;
		"--,"*) #title="${1:3}" 
				type="line";;

		"->") 	type="vector";;
		"->,"*) title="${1:3}" 
				type="vector";;
		"E") 	type="errorbars";;
		"E,"*) title="${1:3}" 
				type="errorbars";;
	esac



	if [ "$title" == "" ]
	then
		title=""
	elif [ "$title" == "" ]
	then
		title="notitle"
	else
		title="title \"$title\""
	fi

	if [ x$nonfile == x ]
	then
		f="\"$f\""
	fi
	
	if [ "$manualspec" != "" ]
	then
		arg="${arg}${arg:+,} $f ${manualspec}"
	elif [ x$nonfile == x ]
	then 
		arg="${arg}${arg:+,} $f ${using} ${axes} with $type ${title}"
	else
		arg="${arg}${arg:+,} $f ${axes} with $type ${title}"
	fi

	[ $# == 0 ] && break
done


com="$extra; $terminal ; plot $xr $yr $arg" 

if [ $fatal == 0 ]
then
	if [ x$output_command_only == x ]
	then
		[ $stdin != 0 ] && mkfifo "$tmpfile"
		
		{
			echo "$com" | gnuplot -persist
			rm -f "$tmpfile"
		}&

		[ $stdin != 0 ] && cat > "$tmpfile" 

		if [ $foreground == 1 ]
		then
			wait
		fi
	else
		echo "$com"
	fi
else
	exit 1
fi
