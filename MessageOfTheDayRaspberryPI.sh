#!/bin/bash

clear

function color (){
  echo "\e[$1m$2\e[0m"
}

function extend (){
  local str="$1"
  let spaces=60-${#1}
  while [ $spaces -gt 0 ]; do
    str="$str "
    let spaces=spaces-1
  done
  echo "$str"
}

function center (){
  local str="$1"
  let spacesLeft=(78-${#1})/2
  let spacesRight=78-spacesLeft-${#1}
  while [ $spacesLeft -gt 0 ]; do
    str=" $str"
    let spacesLeft=spacesLeft-1
  done
  
  while [ $spacesRight -gt 0 ]; do
    str="$str "
    let spacesRight=spacesRight-1
  done
  
  echo "$str"
}

function sec2time (){
  local input=$1
  
  if [ $input -lt 60 ]; then
    echo "$input seconds"
  else
    ((days=input/86400))
    ((input=input%86400))
    ((hours=input/3600))
    ((input=input%3600))
    ((mins=input/60))
    
    local daysPlural="s"
    local hoursPlural="s"
    local minsPlural="s"
    
    if [ $days -eq 1 ]; then
      daysPlural=""
    fi
    
    if [ $hours -eq 1 ]; then
      hoursPlural=""
    fi
    
    if [ $mins -eq 1 ]; then
      minsPlural=""
    fi
    
    echo "$days day$daysPlural, $hours hour$hoursPlural, $mins minute$minsPlural"
  fi
}

borderColor=35
headerLeafColor=32
headerRaspberryColor=31
greetingsColor=32
statsLabelColor=31

borderLine="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
borderTopLine=$(color $borderColor "┏$borderLine┓")
borderBottomLine=$(color $borderColor "┗$borderLine┛")
borderBar=$(color $borderColor "┃")
borderEmptyLine="$borderBar                                                                              $borderBar"

# Header
header="\n$borderTopLine\n$borderEmptyLine\n"
header="$header$borderBar$(color $headerLeafColor "          .~~.   .~~.                                                         ")$borderBar\n"
header="$header$borderBar$(color $headerLeafColor "         '. \ ' ' / .'                                                        ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "          .~ .~~~..~.                      _                          _       ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "         : .~.'~'.~. :     ___ ___ ___ ___| |_ ___ ___ ___ _ _    ___|_|      ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "        ~ (   ) (   ) ~   |  _| .'|_ -| . | . | -_|  _|  _| | |  | . | |      ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "       ( : '~'.~.'~' : )  |_| |__,|___|  _|___|___|_| |_| |_  |  |  _|_|      ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "        ~ .~ (   ) ~. ~               |_|                 |___|  |_|          ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "         (  : '~' :  )                                                        ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "          '~ .~~~. ~'                                                         ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "              '~'                                                             ")$borderBar"

me=$(whoami)

# Greetings
greetings="$borderBar$(color $greetingsColor "$(center "Welcome back, $me!")")$borderBar\n"
greetings="$greetings$borderBar$(color $greetingsColor "$(center "$(date +"%A, %d %B %Y, %T")")")$borderBar"

# System information
read loginFrom loginIP loginDate <<< $(last $me --time-format iso -2 | awk 'NR==2 { print $2,$3,$4 }')

# TTY login
if [[ $loginDate == - ]]; then
  loginDate=$loginIP
  loginIP=$loginFrom
fi

if [[ $loginDate == *T* ]]; then
  login="$(date -d $loginDate +"%A, %d %B %Y, %T") ($loginIP)"
else
  # Not enough logins
  login="None"
fi

label0="$(extend "OS: $(cat /etc/os-release | sed 's/.*PRETTY_NAME=//' | head -n1), Kernel: $(uname -a | awk -F ' ' '{print $3}')")"
label0="$borderBar  $(color $statsLabelColor "RaspberryPi4..:") $label0$borderBar"

label1="$(extend "$login")"
label1="$borderBar  $(color $statsLabelColor "Last Login....:") $label1$borderBar"

uptime="$(sec2time $(cut -d "." -f 1 /proc/uptime))"
uptime="$uptime ($(date -d "@"$(grep btime /proc/stat | cut -d " " -f 2) +"%d-%m-%Y %H:%M:%S"))"

label2="$(extend "$uptime")"
label2="$borderBar  $(color $statsLabelColor "Uptime........:") $label2$borderBar"

label3="$(extend "$(free -m | awk 'NR==2 { printf "Total: %sMB, Used: %sMB, Free: %sMB",$2,$3,$4; }')")"
label3="$borderBar  $(color $statsLabelColor "Memory........:") $label3$borderBar"

label4="$(extend "$(df -h ~ | awk 'NR==2 { printf "Total: %sB, Used: %sB, Free: %sB",$2,$3,$4; }')")"
label4="$borderBar  $(color $statsLabelColor "Disk usage....:") $label4$borderBar"

label5="$(extend "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-9")ºC")"
label5="$borderBar  $(color $statsLabelColor "Temperature...:") $label5$borderBar"

label6="$(extend "Internal IP: $(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | tr -s '\n' ' ')Public IP: $(wget -q -O - http://icanhazip.com/ | tail)")"
label6="$borderBar  $(color $statsLabelColor "IP Addresses..:") $label6$borderBar"

label7="$(extend "Torricella in Sabina: $(curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|IT|IT007|TORRICELLAINSABINA|" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p')")"
label7="$borderBar  $(color $statsLabelColor "Weather.......:") $label7$borderBar"

label8="$(extend "$(ps ax | wc -l | tr -d " ") running process")"
label8="$borderBar  $(color $statsLabelColor "Load..........:") $label8$borderBar"

label9="$(extend "Total: $(who | grep -Po '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' | wc -l), List IP: $(who | grep -Po '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' | awk '{print}' ORS=' ') ")"
label9="$borderBar  $(color $statsLabelColor "pts connected.:") $label9$borderBar"

stats="$label0\n$label1\n$label2\n$label3\n$label4\n$label5\n$label6\n$label7\n$label8\n$label9"

# Print motd
echo -e "$header\n$borderEmptyLine\n$greetings\n$borderEmptyLine\n$stats\n$borderEmptyLine\n$borderBottomLine\n" 

# Print Software 
echo "
 ============================ Installed software ===================
| 0. MessageOfTheDayRaspberryPI (https://github.com/stefanostatuti/MessageOfTheDayRaspberry)
| N.
 =================================================================="

