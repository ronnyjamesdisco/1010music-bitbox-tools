# 1010music-bitbox-tools

Bitbash: bash script for batch converting samples to 48k/24bit and optionally normalize them. Will crawl through subfolders...


# dependencies: 
SoX (Sound eXchange) / apt install sox

bash 4 or higher (globstar globbing option for **)

# usage: 
./bitbash.sh [OPTION]  

Option: -n for normalize

Initial purpose for writing this script was migrating my sample library to 1010Music´s Bitbox 44.1k/16bit->48k/24bit wav. The batch process will read Wave, AIFF and SD2 files as long as they come with the usual file endings.

