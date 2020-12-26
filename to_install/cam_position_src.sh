#!/bin/bash

HRES=$(fbset -i | awk '/geometry/ {print $2}')
VRES=$(fbset -i | awk '/geometry/ {print $3}')
HALF_HRES=$(($HRES / 2))
HALF_VRES=$(($VRES / 2))


top_left_pos="0 0 $(($HALF_HRES)) $(($HALF_VRES))"
top_right_pos="$HALF_HRES 0 $(($HRES)) $(($HALF_VRES))"
bottom_left_pos="0 $HALF_VRES $(($HALF_HRES)) $(($VRES))"
bottom_right_pos="$HALF_HRES $HALF_VRES $(($HRES)) $(($VRES))"
full_screen="0 0 $HRES $VRES"
