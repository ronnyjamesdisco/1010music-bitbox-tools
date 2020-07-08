#!/bin/bash
# dependencies: SoX (Sound eXchange) / apt install sox
# bash 4 or higher (globstar globbing option for **)
#
# usage: ./test.sh [OPTION]  
# Option: -n for normalize
#
# Author: <ronnyjamesdisco@googlemail.com>
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
#
# Initial purpose for writing this script was migrating my sample library to 
# 1010Music´s Bitbox 44.1k/16bit->48k/24bit wav. The batch process will read 
# Wave, AIFF and SD2 files as long as they come with the usual file endings.
# 
#####################################################################################
# Preferences
SAMPLERATE=48000 					# Hz value (eg 48000)
BITDEPTH=24							# resolution in BITs (eg 24)
NORMALIZEVALUE="-0.1"				# normalize gain in dB	
CONVERSIONFOLDER="SoXconverted"		# name of the folder in home directory
 
# DO NOT EDIT BELOW
#####################################################################################
## return descriptive message and exit if SoX is not installed  

SOXINSTALLED=sox
[[ $(type -P "$SOXINSTALLED") ]] || { echo "SoX (Sound eXchange) needs to be installed for this script to run. Please install from http://sox.sourceforge.net/" 1>&2; exit 1; }

#####################################################################################
# check and initialize some stuff

SCRIPTNAME=`basename "$0"`								# name of our script
SOURCEPATH=$PWD											# store current directory path
SOURCEPATHBASE="$(basename "$SOURCEPATH")"				# get source folder name 
DESTINATIONBASE=""$HOME"/"$CONVERSIONFOLDER""			# where to save 
if [ -n "$1" ] && [ $1 == "-n" ]						# was the script called with the -n parameter?
	then NORMALIZE=1 ; NORMALIZEPARAMETER="norm $NORMALIZEVALUE" 	# flag and get normalize value
	else NORMALIZE=0 ; NORMALIZEPARAMETER=""			# or flag null
	fi
SOXCONVERT="sox -V1 -b $BITDEPTH -r $SAMPLERATE"		# alias sox /w format values
#####################################################################################
# Hello message and confirmation dialogue
 
	echo $SCRIPTNAME "will process WAV or AIFF samples in:"
	echo $SOURCEPATH 
	echo
	echo "and convert them into 1010 Music´s Bitbox native format (WAV 48kHz 24 Bit)." 
	echo
	echo "Files will be written to:" 
	echo $DESTINATIONBASE"/"$SOURCEPATHBASE 
	echo
	echo "Subfolder structures will be preserved. "
	echo 
	echo  "CAUTION: Same name files in the destination folder will be overwritten!" 
	echo  
	if [ $NORMALIZE == "0" ] 							# normalize?
		then echo "Samples will not get normalized - to include normalization option cancel and re-invoke: $SCRIPTNAME -n" 
		else echo "Samples will get normalized!"
	fi 	 
	echo 
	read -p  "Do you want to continue? (y)? " -n 1 -r  	# confirmation (y/n)
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]								# Anything but "y" -> Cancel
		then
			exit 1
	fi													# "Y" -> go ahead!
	
#####################################################################################
# Main loop
# crawling through all directories for audio files, convert and dump to destination
#
# global command implementation from superuser / mpy https://superuser.com/a/612002/1195749

function bitbot() {								# define as function 
  shopt -s globstar								# enable filename globbing extension / bash 4.2 and higher only!
  # If set, the pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
  for d in ./**/ 		# for all directories
	do
		cd "$d"									# dive into subdirs
		SUBDIR=${d//$SOURCEPATH/}			 	# get SUBDIR name // a bit ugly with the /./ in resulting paths but this is as good as I get it for now
		CONVERTDIR=""$DESTINATIONBASE"/"$SOURCEPATHBASE"/"$SUBDIR""	# define destination directory 
			mkdir -p "$CONVERTDIR"				# make destination

	for file in *		# for all files in directories 	
		do ( 
						# 1.) Wave files 
			if [[ $file == *.wav ]] || [[ $file == *.Wav ]] || [[ $file == *.WAV ]]	
				then 	
				OUTFILE=$CONVERTDIR/$file								# def dest file
				$SOXCONVERT ./"$file" "$OUTFILE" $NORMALIZEPARAMETER  	# convert & write
				echo $OUTFILE
			fi
						# 2.) other file types append .wav (double suffix to avoid same name with .wav files previously processed)	
			if [[ $file == *.aif ]] || [[ $file == *.Aif ]] || [[ $file == *.AIF ]] || [[ $file == *.aiff ]] || [[ $file == *.Aiff ]] || [[ $file == *.AIFF ]] || [[ $file == *.sd2 ]] || [[ $file == *.SD2 ]]
				then
				OUTFILE=$CONVERTDIR/$file.wav							# def dest file
				$SOXCONVERT ./"$file" "$OUTFILE" $NORMALIZEPARAMETER  	# convert & write
				echo $OUTFILE
			fi
		) done 			# done with the files
    cd "$SOURCEPATH"	# jump back to where we started
	done				# done with this directory
}						# done with all directories
bitbot 					# call the function
exit 