#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

cam_num_file="$DIR/cam_num"
source $DIR/cam_position_src.sh

chname=("Front")
chname+=("Back")
chname+=("Brama")
chname+=("Balkon")


cam_on_top=0
cam_num=4

if [ -e $cam_num_file ];then
	temp=$(cat $cam_num_file)
	if [ "${temp:0:2}" == "ch" ];then
		cam_on_top=${temp:2}
	fi
	if [ "$temp" == "allcam" ];then
		cam_on_top=0
	fi
fi


while read -d . SOCKET; do
	case $SOCKET in
		next)
		cam_on_top=$((cam_on_top + 1));
		if [ $cam_on_top -gt $cam_num ];then
			cam_on_top=0
		fi
		;;
		prev)
		cam_on_top=$((cam_on_top - 1));
		if [ $cam_on_top -lt 0 ];then
			cam_on_top=$cam_num
		fi
		;;
		cam1)
			cam_on_top=1
		;;
		cam2)
			cam_on_top=2
		;;
		cam3)
			cam_on_top=3
		;;
		cam4)
			cam_on_top=4
		;;
		allcam)
			cam_on_top=0
		;;
		*)
		;;
	esac

	if [ $cam_on_top -gt 0 ];then
		for ((l = 1; l <= $cam_num; l++));do			
			$DIR/omxplayer-dbus-control.sh ch$l hidevideo
			$DIR/omxplayer-dbus-control.sh ch$l setvideopos $full_screen
		done
		for ((l = 1; l <= $cam_num; l++));do
			if [ $l -eq $cam_on_top  ];then
				$DIR/omxplayer-dbus-control.sh ch$l setlayer 5
				$DIR/omxplayer-dbus-control.sh ch$l unhidevideo
			else
				$DIR/omxplayer-dbus-control.sh ch$l setlayer 1
			fi
		done
		text="ch$cam_on_top"
		send="0 10 60 ${chname[cam_on_top - 1]}!\n"
	else
		$DIR/omxplayer-dbus-control.sh ch1 setvideopos $top_left_pos
		$DIR/omxplayer-dbus-control.sh ch2 setvideopos $top_right_pos
		$DIR/omxplayer-dbus-control.sh ch3 setvideopos $bottom_left_pos
		$DIR/omxplayer-dbus-control.sh ch4 setvideopos $bottom_right_pos
		for ((l = 1; l <= $cam_num; l++));do
			$DIR/omxplayer-dbus-control.sh ch$l unhidevideo
		done
		text="allcam"
		send="0 5 40 ${chname[0]}!\n960 5 40 ${chname[1]}!\n0 548 40 ${chname[2]}!\n960 548 40 ${chname[3]}!\n"
	fi

	echo "$text" > $DIR/cam_num

	if [ -e /tmp/hello_font_by_raszit ]; then
		echo -e "$send" | socat STDIO UNIX-CONNECT:/tmp/hello_font_by_raszit,connect-timeout=1
	fi

done

exit 0

