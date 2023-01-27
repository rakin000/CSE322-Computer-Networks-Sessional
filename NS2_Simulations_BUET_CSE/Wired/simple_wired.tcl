#Create a simulator object
set ns [new Simulator]


#Open the NAM file and trace file
set nam_file [open animation.nam w]
set trace_file [open trace.tr w]
$ns namtrace-all $nam_file
$ns trace-all $trace_file

$ns color 0 White
$ns color 1 Red 
$ns color 2 Green
$ns color 3 Blue 
$ns color 4 Yellow

#Create two nodes
set n0 [$ns node]
set n1 [$ns node]

#Create links between the nodes
# ns <link-type> <node1> <node2> <bandwidth> <delay> <queue-type>
$ns duplex-link $n0 $n1 2Mb 10ms DropTail


#Set Queue Size of link (n0-n1) to 20
$ns queue-limit $n0 $n1 50


#Setup a TCP connection
#Setup a flow
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1 

set sink1 [new Agent/TCPSink]
$ns attach-agent $n0 $sink1

$ns connect $tcp $sink
$ns connect $tcp1 $sink1 
$tcp set fid_ 2
$tcp1 set fid_ 1



#Setup a FTP Application over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

set ftp2 [new Application/FTP] 
$ftp2 attach-agent $tcp1
$ftp2 set type_ FTP 

#Schedule events for the CBR and FTP agents
$ns at 1.0 "$ftp start"
$ns at 40.0 "$ftp stop"
$ns at 1.0 "$ftp2 start"
$ns at 40.0 "$ftp2 stop"


#Call the finish procedure after 5 seconds of simulation time
$ns at 50.0 "finish"

#Define a 'finish' procedure
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace 
    #Close the NAM trace file
    close $nam_file
    close $trace_file
    #Execute NAM on the trace file
    # exec nam out.nam &
    puts "Finishing Simulation"
    exit 0
}



#Run the simulation
$ns run
