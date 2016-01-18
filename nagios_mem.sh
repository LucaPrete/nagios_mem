#!/usr/bin/env bash

#Set script name
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Set default values
MEM_WARNING=20
MEM_CRITICAL=10

# help function
function printHelp {
  echo -e \\n"Help for $SCRIPT"\\n
  echo -e "The script returns the amount of memory available - not including buffers"\\n
  echo -e "Basic usage: $SCRIPT -w {warning} -c {critical}"\\n
  echo "Command switches are optional, default values for warning is 20% and critical is 10%"
  echo "-w - Sets warning value for Memory Usage. Default is 20%"
  echo "-c - Sets critical value for Memory Usage. Default is 10%"
  echo -e "-h  - Displays this help message"\\n
  echo -e "Example: $SCRIPT -w 80 -c 90"\\n
  echo -e \\n\\n"Author: Luca Prete, luca@onlab.us"\\n
  echo -e "Download from https://github.com/LucaPrete/nagios_mem.git"
  exit 1
}

# regex to check is OPTARG an integer
re='^[0-9]+$'

while getopts :w:c:h FLAG; do
  case $FLAG in
    w)
      if ! [[ $OPTARG =~ $re ]] ; then
        echo "error: Not a number" >&2; exit 1
      else
        MEM_WARNING=$OPTARG
      fi
      ;;
    c)
      if ! [[ $OPTARG =~ $re ]] ; then
        echo "error: Not a number" >&2; exit 1
      else
        MEM_CRITICAL=$OPTARG
      fi
      ;;
    h)
      printHelp
      ;;
    \?)
      echo -e \\n"Option - $OPTARG not allowed."
      printHelp
      exit 2
      ;;
  esac
done

shift $((OPTIND-1))

total_mem=$(free -k | sed -n 2p | awk '{print $2}')
used_mem=$total_mem-available_mem
avail_mem=$(free -k | sed -n 3p | awk '{print $4}')
avail_mem_perc=$((($avail_mem*100)/$total_mem))

message="$avail_mem_perc% ($avail_mem kB free!) | TOTAL=$total_mem;;;; USED=$used_mem;;;; AVAILABLE=$avail_mem;;;;"

if [ "$avail_mem_perc" -ge "$MEM_WARNING" ]; then
  echo "OK - $message"
  exit 0
elif [ "$avail_mem_perc" -ge "$MEM_CRITICAL" ] && [ "$avail_mem_perc" -le "$MEM_WARNING" ]; then
  echo "WARNING - $message"
  exit 1
elif [ "$avail_mem_perc" -le "$MEM_CRITICAL" ]; then
  echo "CRITICAL - $message"
  exit 1
else
  echo "UNKNOWN - $message"
  exit 3
fi