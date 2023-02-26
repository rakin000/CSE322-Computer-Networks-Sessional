set ns [new Simulator]

# trace file
set trace_file [open mysim_trace.tr w]
$ns trace-all $trace_file

# Define options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          CMUPriQueue ; #Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       100                      ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSR                     ;# ad-hoc routing protocol 
set val(energyModel)  "EnergyModel"		;# energy model 
set val(rxPower)	   1.35				   ;# receive power consumption 
set val(txPower) 	    1.7			   		;# transmit power consumption
set val(initialEnergy)  100.0				;# initial energy 
set val(idlePower)	.05			; #idle power 
set val(sleepPower)	.001			; #sleep power 
set val(side)         500                      ;# square area. area side    
set val(topoWidth)	1670 		       ; # width of topography 
set val(topoHeight) 	970			; # height of topography
set val(nn)           50                       ;# number of mobilenodes
set val(nf)           20                        ;# number of flows      
set val(time)         50                        ; # time of simulation 
set val(execnam)      0                         ;# execute nam after done
set val(execawk)      0                         ;# execute awk after done 
set val(transportProtocol) udp 			; # transport layer protocol  
set val(speed) 		5		                ; # top speed of nodes
set val(packetSize) 	256				;

Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 3.65262e-10 ;#250m
Phy/WirelessPhy set RXThresh_ 3.65262e-10 ;#250m
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.00

for {set i 0} { $i+1 < $argc } { set i [expr $i+2] } {
    if { [string equal [lindex $argv $i] "-nn"] } {
        # puts "here" 
        set val(nn) [lindex $argv [expr $i+1] ] 
    } elseif {[lindex $argv $i] == "-nf"} {
        set val(nf) [lindex $argv [expr $i+1] ]
    } elseif {[lindex $argv $i] == "-side"} {
        set val(side) [lindex $argv [expr $i+1] ]
    } elseif {[lindex $argv $i] == "-qlen"} {
        set val(ifqlen) [lindex $argv [expr $i+1] ]
    } elseif {[lindex $argv $i] == "-execnam" } {
        set val(execnam) [lindex $argv [expr $i+1] ]
    } elseif {[lindex $argv $i] == "-execawk" } {
        set val(execawk) [lindex $argv [expr $i+1] ]
    } elseif { [lindex $argv $i] == "-transportProtocol" } {
        set val(transportProtocol) [lindex $argv [expr $i+1] ]
    } elseif { [lindex $argv $i] == "-speed" } {
	set val(speed) [lindex $argv [expr $i+1] ]
    } elseif { [lindex $argv $i] == "-packetSize" } {
	set val(packetSize) [lindex $argv [expr $i+1] ]
    }
}

# nam file
set nam_file [open mysim_anim.nam w]
$ns namtrace-all-wireless $nam_file $val(side) $val(side)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(topoWidth) $val(topoHeight)

set uniform_rnd_coord_posX [new RandomVariable/Uniform]
$uniform_rnd_coord_posX set min_ 1
$uniform_rnd_coord_posX set max_ [expr $val(topoWidth)-1] 

set uniform_rnd_coord_posY [new RandomVariable/Uniform]
$uniform_rnd_coord_posY set min_ 1
$uniform_rnd_coord_posY set max_ [expr $val(topoHeight)-1] 

set uniform_rnd_node [new RandomVariable/Uniform]
$uniform_rnd_node set min_ 0 
$uniform_rnd_node set max_ [expr $val(nn)-1]

# general operation director for mobilenodes
create-god $val(nn)

$ns node-config -energyModel $val(energyModel) \
		-rxPower $val(rxPower) \
                -txPower $val(txPower) \
                -initialEnergy $val(initialEnergy) \
		-idlePower $val(idlePower) \
		-sleepPower $val(sleepPower) \
		-adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF
		    

# create nodes
for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 1  

    $node($i) set X_ [expr round([$uniform_rnd_coord_posX value])] 
    $node($i) set Y_ [expr round([$uniform_rnd_coord_posY value])] 
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 20
} 

# set src [expr round([$uniform_rnd_node value])]  
set src [expr int(1000 * rand()) % $val(nn)]
puts "source = $src" 

set dest -1 ;# [expr round([$uniform_rnd_node value])]
set dist 0 ;# [expr $val(side)*$val(side) ]
set srcX [$node($src) set X_]
set srcY [$node($src) set Y_]

for {set i 0} {$i < $val(nn) } {incr i} {
    if { $i == $src } {
    	continue ;
    }

    set x [$node($i) set X_ ] 
    set y [$node($i) set Y_ ] 
	
    set tdist [expr ($x - $srcX)*($x - $srcX) + ($y - $srcY)*($y - $srcY) ] 
    if { $tdist > $dist } {
        set dist [expr $tdist] 
        set dest [expr $i] 
    }
}

puts "destination = $dest"

if { [string equal $val(transportProtocol) "tcp"] } {
    set tcp [new Agent/TCP] 
    set tcp_sink [new Agent/TCPSink] 
    $ns attach-agent $node($src) $tcp 
    $ns attach-agent $node($dest) $tcp_sink 
    $ns connect $tcp $tcp_sink 
    $tcp set fid_ 1 

    set ftp [new Application/FTP] 
    $ftp attach-agent $tcp 
    $ns at 0.5 "$ftp start"
} else {
    set udp [new Agent/UDP]
    set udp_sink [new Agent/Null]
    $ns attach-agent $node($src) $udp 
    $ns attach-agent $node($dest) $udp_sink
    $ns connect $udp $udp_sink
    $udp set fid_ 1 

    set cbr [new Application/Traffic/CBR]
    $cbr attach-agent $udp

    $cbr set type_ CBR
    $cbr set packet_size_ $val(packetSize)  
    $cbr set rate_ 128kb 
# $cbr set random_ false
    $ns at 0.5 "$cbr start"  
}

for {set t 1.0 } {$t < $val(time) } { set t [expr $t+5] } {
    for {set i 0} {$i < $val(nn) } {incr i} {
        $ns at $t "$node($i) setdest [expr round([$uniform_rnd_coord_posX value])] [expr round([$uniform_rnd_coord_posY value])] [expr int(rand()*1000)%$val(speed)+1]" 
    }
}



for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(time) "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file val
    $ns flush-trace
    close $trace_file
    close $nam_file
    if { $val(execnam) == 1 } {
        exec nam mysim_anim.nam & 
    }
    if { $val(execawk) == 1 } {
        if { $val(transportProtocol) == "udp" } {
            exec awk -v exp_packet_type=cbr -f parse.awk mysim_trace.tr &
        } elseif { $val(transportProtocol) == "tcp" } {
            exec awk -v exp_packet_type=tcp -f parse.awk mysim_trace.tr &
        }
    }
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at [expr $val(time)+.0001] "finish"
$ns at [expr $val(time)+.0002] "halt_simulation"

# Run simulation
puts "Simulation starting"
$ns run

