# Netport
Script to detect devices on the network.

You can specify the network mask, number of ports and OS detection.

## Usage

	 -i 		 To specify your ip address		
	 -m 		 To specify the mask network, by default is /24		
	 -p 		 To specify the number of ports to scan on a device, by default is 10000		
	 -o 		 OS Scan
	 -h 		 Show this help panel	

## Installation

```
git clone github.com/c4rl0s01/Netport.git
cd Netport
chmod +x netport.sh
```

### Example
```
./netport.sh -i IP -p PORTS -o
```

