speed=("5" "10" "15" "20")
pktsize=("128" "256" "512" "1024") 

runner_func() {
	filename="results.csv"

	if [[ $# -ge 1 ]]; then 
	   filename=$1
	fi

	echo -n "" > $filename
	echo "Speed,Packet Size,Sent Packets,Dropped Packets,Received Packets,Throughput,Average Delay,Delivery Ratio,Drop Ratio,Energy Consumption">>$filename

	packetSize=256

	for speedval in "${speed[@]}" 
	do		
	   # echo -n "ns scenario1.tcl -speed $speedval -execawk 1 >> $filename" >> $filename
	   echo -n "$speedval, $packetSize," >> $filename
	   ns scenario1.tcl -speed $speedval -packetSize $packetSize -execawk 1 | tail -n1 >> $filename 
	    #awk -f parse.awk mysim_trace.tr | tail -1 >> $filename      
	    #awk -v exp_packet_type=udp -f parse.awk mysim_trace.tr | tail -1 >> $filename
	done 

	speedval=5
	for packetSize in "${pktsize[@]}" 
	do		
	   # echo -n "ns scenario1.tcl -speed $speedval -execawk 1 >> $filename" >> $filename
	   echo -n "$speedval, $packetSize," >> $filename
	   ns scenario1.tcl -speed $speedval -packetSize $packetSize -execawk 1 | tail -n1 >> $filename 
	    #awk -f parse.awk mysim_trace.tr | tail -1 >> $filename      
	    #awk -v exp_packet_type=udp -f parse.awk mysim_trace.tr | tail -1 >> $filename
	done 
}

iteration=10

if [[ $# -ge 1 ]]; then 
	iteration=$1
fi 

for ((i=0;i<iteration;i++)) 
do 
	runner_func "result${i}.csv"
done
