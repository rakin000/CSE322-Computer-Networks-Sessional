side=("250" "500" "750" "1000" "1250") 
nn=("20" "40" "60" "80" "100")
nf=("10" "20" "30" "40" "50")

echo -n "" > results.csv
echo "Command,Nodes,Flows,Area,Sent Packets,Dropped Packets,Received Packets,Throughput,Average Delay,Delivery Ratio,Drop Ratio">>results.csv

nnval=40
nfval=20
sideval=500 

for nnval in "${nn[@]}" 
do		
    ns mysim.tcl -nn $nnval -nf $nfval -side $sideval 
    echo -n "ns mysim.tcl -nn $nnval -nf $nfval -side $sideval" >> results.csv
	echo -n ",$nnval,$nfval,$sideval x $sideval,">>results.csv
 	awk -f parse.awk mysim_trace.tr | tail -1 >> results.csv      
done 
nnval=40
nfval=20
sideval=500 

for nfval in "${nf[@]}" 
do		
    ns mysim.tcl -nn $nnval -nf $nfval -side $sideval 
    echo -n "ns mysim.tcl -nn $nnval -nf $nfval -side $sideval" >> results.csv
	echo -n ",$nnval,$nfval,$sideval x $sideval,">>results.csv
 	awk -f parse.awk mysim_trace.tr | tail -1 >> results.csv      
done 
nnval=40
nfval=20
sideval=500 

for sideval in "${side[@]}" 
do		
    ns mysim.tcl -nn $nnval -nf $nfval -side $sideval 
    echo -n "ns mysim.tcl -nn $nnval -nf $nfval -side $sideval" >> results.csv
	echo -n ",$nnval,$nfval,$sideval x $sideval,">>results.csv
 	awk -f parse.awk mysim_trace.tr | tail -1 >> results.csv      
done 

 
