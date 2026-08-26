#!/bin/sh

# Use the unallocated eMMC tail on the 128 GB NN6000 v2 as persistent data.
device=/dev/mmcblk0
partition=${device}p27
target=/mnt/data

[ "$(cat /tmp/sysinfo/board_name 2>/dev/null)" = "link,nn6000-v2" ] || exit 0
[ -b "$device" ] && [ -b "${device}p26" ] || exit 0

sectors=$(cat /sys/class/block/mmcblk0/size 2>/dev/null)
[ "${sectors:-0}" -gt 10000000 ] || exit 0

if [ ! -b "$partition" ]; then
	start=$(cat /sys/class/block/mmcblk0/mmcblk0p26/start)
	size=$(cat /sys/class/block/mmcblk0/mmcblk0p26/size)
	start=$((start + size))
	start=$(((start + 2047) / 2048 * 2048))

	parted -s -f "$device" unit s mkpart data f2fs "${start}s" 100% || exit 1
	partprobe "$device"

	for attempt in $(seq 1 10); do
		[ -b "$partition" ] && break
		sleep 1
	done
	[ -b "$partition" ] || exit 1

	# Avoid a full-device discard on first boot; it can stall eMMC for minutes.
	mkfs.f2fs -f -t 0 -l data "$partition" || exit 1
fi

/etc/init.d/mount-data enable
/etc/init.d/mount-data start
