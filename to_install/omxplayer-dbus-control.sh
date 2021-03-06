#!/bin/bash

#set -x
DBUS_NAME=org.mpris.MediaPlayer2.omxplayer.$1
#DBUS_NAME=$1
OMXPLAYER_DBUS_ADDR="/tmp/omxplayerdbus.$1.${USER:-root}"
OMXPLAYER_DBUS_PID="/tmp/omxplayerdbus.$1.${USER:-root}.pid"
export DBUS_SESSION_BUS_ADDRESS=`cat $OMXPLAYER_DBUS_ADDR`
export DBUS_SESSION_BUS_PID=`cat $OMXPLAYER_DBUS_PID`

[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && { echo "Must have DBUS_SESSION_BUS_ADDRESS" >&2; exit 1; }

case $2 in
status)
	duration=`dbus-send --print-reply=literal --session --reply-timeout=500 --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:"org.mpris.MediaPlayer2.Player" string:"Duration"`
	[ $? -ne 0 ] && exit 1
	duration="$(awk '{print $2}' <<< "$duration")"

	position=`dbus-send --print-reply=literal --session --reply-timeout=500 --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:"org.mpris.MediaPlayer2.Player" string:"Position"`
	[ $? -ne 0 ] && exit 1
	position="$(awk '{print $2}' <<< "$position")"

	playstatus=`dbus-send --print-reply=literal --session --reply-timeout=500 --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:"org.mpris.MediaPlayer2.Player" string:"PlaybackStatus"`
	[ $? -ne 0 ] && exit 1
	playstatus="$(sed 's/^ *//;s/ *$//;' <<< "$playstatus")"

	paused="true"
	[ "$playstatus" == "Playing" ] && paused="false"
	echo "Duration: $duration"
	echo "Position: $position"
	echo "Paused: $paused"
	;;

volume)
	volume=`dbus-send --print-reply=double --session --reply-timeout=500 --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:"org.mpris.MediaPlayer2.Player" string:"Volume" ${3:+double:}$3`
	[ $? -ne 0 ] && exit 1
	volume="$(awk '{print $2}' <<< "$volume")"
	echo "Volume: $volume"
	;;

pause)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:16 >/dev/null
	;;

stop)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:15 >/dev/null
	;;

seek)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Seek int64:$3 >/dev/null
	;;

setposition)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.SetPosition objpath:/not/used int64:$3 >/dev/null
	;;

setalpha)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.SetAlpha objpath:/not/used int64:$3 >/dev/null
	;;

setlayer)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.SetLayer int64:$3 >/dev/null
	;;

setvideopos)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.VideoPos objpath:/not/used string:"$3 $4 $5 $6" >/dev/null
	;;

setvideocroppos)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.SetVideoCropPos objpath:/not/used string:"$3 $4 $5 $6" >/dev/null
	;;

setaspectmode)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.SetAspectMode objpath:/not/used string:"$3" >/dev/null
	;;

hidevideo)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:28 >/dev/null
	;;

unhidevideo)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:29 >/dev/null
	;;

volumeup)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:18 >/dev/null
	;;

volumedown)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:17 >/dev/null
	;;
	
togglesubtitles)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:12 >/dev/null
	;;
	
hidesubtitles)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:30 >/dev/null
	;;

showsubtitles)
	dbus-send --print-reply=literal --session --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Action int32:31 >/dev/null
	;;
getsource)
	source=$(dbus-send --print-reply=literal --session --reply-timeout=500 --dest=$DBUS_NAME /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.GetSource)
	[ $? -ne 0 ] && exit 1
	echo "$source" | sed 's/^ *//'
	;;
*)
	echo "usage: $0 status|pause|stop|seek|volumeup|volumedown|setposition [position in microseconds]|hidevideo|unhidevideo|togglesubtitles|hidesubtitles|showsubtitles|setvideopos [x1 y1 x2 y2]|setvideocroppos [x1 y1 x2 y2]|setaspectmode [letterbox,fill,stretch,default]|setalpha [alpha (0..255)]|getsource" >&2
	exit 1
	;;
esac
