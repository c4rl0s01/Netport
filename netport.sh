#!/bin/bash

trap ctrl_c INT 



function ctrl_c(){
	
	echo -e "\n\n[!] Exiting...\n" 
	rm  /tmp/list 
	tput cnorm   2>/dev/null
	exit 1
}
	


function help(){
	
	echo -e "[+] NetPort Help Panel [+]\t\t\n"
	echo -e "\t -i \t\t To specify your ip address\t\t"
	echo -e "\t -m \t\t To specify the mask network, by default is /24\t\t"
	echo -e "\t -p \t\t To specify the number of ports to scan on a device, by default is 10000\t\t"
	echo -e "\t -o \t\t OS Scan"
	echo -e "\t -h \t\t Show this help panel\t\t\n"
	
	exit 0

}

function detect_ip(){

	new_ip=$(echo "$1" | grep -o -E "[[:digit:]]{1,3}(\.|\-)[[:digit:]]{1,3}(\.|\-)[[:digit:]]{1,3}")
	echo "$new_ip"
}

function calculate_devices(){

	num_devices=$((2**(32-$1)-2))
	
	echo "$num_devices"

}



function netport(){

	

        ip=$(detect_ip $1)
     
        devices=$2
        
	list="/tmp/list"

        echo -e " [*] Searching on $ip.0/$2  [*]\n"
        for last_num in $(seq 1 $devices); do
		ip_find=$(echo "$ip.$last_num")
		if [[ ! $1 == $ip_find     ]]; then
			 {
            		ping -c 1 -W 1 "$ip_find" &> /dev/null
                	if [ $? -eq 0 ]; then
				echo -e "[+] Host discovered: $ip_find [+]\n "
				echo "$ip_find" >> /tmp/list
           		 fi
        	} &
		fi
               
        done; wait
        
        if [[ $4 -eq 1 && -s /tmp/list ]]; then
		
		while read  ip_os; do
			
			ttl=$(ping -c 1 -W 1 $ip_os | grep -oP 'ttl=\K([0-9]+)')
			
			if [ $ttl -le 64 ]; then
				echo -e "$ip_os -> Linux\n"

			else
				echo -e "$ip_os -> Windows\n"
			fi		
		done < "$list"

	fi

        if [[ -s  /tmp/list  ]]; then

                while read ip_port; do
                	echo -e "[*] Searching ports on $ip_port [*]\n"
                	for port in $(seq 0 $3); do
	                	timeout 1 bash -c "echo '' > /dev/tcp/$ip_port/$port" 2>/dev/null && echo "Port open $port -> $ip_port:$port " &
                	
                	done; wait

			echo -e "\n\n"
                done < "$list"

        else 
        	echo -e "[!] No host have been discovered [!]\n"
        	rm /tmp/list
        	exit 0

	fi
	
	

	rm /tmp/list

}



devices_activated=0
os_detection_enabled=0
ports=10000

while getopts "i:m:p:ho" value; do

        case $value in
                i) address=$OPTARG;;
                m) mask=$OPTARG; let devices_activated+=1;;
                h) help;;
                p) ports=$OPTARG;;
                o) let os_detection_enabled+=1;;
		\?) echo -e "Invalid option\n"; help;;
        esac
done

if [ $# -eq 0 ]; then
	help

else
	touch /tmp/list
	
	if [ $devices_activated -eq 1 ]; then
		devs=`calculate_devices $mask`
	else
		devs=255
	fi	
	netport $address $devs $ports $os_detection_enabled
fi
