# simulator
set ns [new Simulator]


# Define options
set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          CMUPriQueue ; #Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                      ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSR                     ;# ad-hoc routing protocol
set val(energyModel)  "EnergyModel"             ;# energy model
set val(rxPower)            3.0                            ;# receive power consumption
set val(txPower)            3.0                                 ;# transmit power consumption
set val(initialEnergy)  100.0                           ;# initial energy
set val(idlePower)      .45                     ; #idle power
set val(sleepPower)     .05                     ; #sleep power
set val(side)         500                      ;# square area. area side
set val(nn)           40                       ;# number of mobilenodes
set val(nf)           20                        ;# number of flows
set val(time)         100                        ; # time of simulation
set val(execnam)      0                         ;# execute nam after done
set val(execawk)      0                         ;# execute awk after done
set val(transportProtocol) tcp                  ; # transport layer protocol  

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
    }
}


# trace file
set trace_file [open mysim_trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open mysim_anim.nam w]
$ns namtrace-all-wireless $nam_file $val(side) $val(side)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(side) $val(side)


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
                                                 

# create nodes
for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0       ;# disable random motion

    $node($i) set X_ [expr int(rand()*$val(side))]
    $node($i) set Y_ [expr int(rand()*$val(side))]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 20       ;# question: initial_node_pos er kaj ki
    $ns at [expr int(8 * rand()) + 2] "$node($i) setdest [expr int(rand()*($val(side)-1))+1] [expr int(rand()*($val(side)-1))+1] [expr int(100 * rand()) % 4 + 1]"
} 


set dest [expr int(rand()*$val(nn))]
puts "------------------"
puts "dst is: $dest"


# Traffic

for {set i 0} {$i < $val(nf)} {incr i} {
    set src [expr int(rand()*$val(nn))]
    while {$src == $dest} {
        set src [expr int(rand()*$val(nn))]
    }    
    puts "src is: $src"

    if { [string equal $val(transportProtocol) "tcp"] } {
        set tcp [new Agent/TCP] 
        set tcp_sink [new Agent/TCPSink] 
        $ns attach-agent $node($src) $tcp 
        $ns attach-agent $node($dest) $tcp_sink 
        $ns connect $tcp $tcp_sink 
        $tcp set fid_ [expr $i+1] 

        set ftp [new Application/FTP] 
        $ftp attach-agent $tcp 
        $ns at 0.5 "$ftp start"
    } else {
        set udp [new Agent/UDP]
        set udp_sink [new Agent/Null]
        $ns attach-agent $node($src) $udp 
        $ns attach-agent $node($dest) $udp_sink
        $ns connect $udp $udp_sink
        $udp set fid_   [expr $i+1] 

        set cbr [new Application/Traffic/CBR]
        $cbr attach-agent $udp
    
        $cbr set type_ CBR
        $cbr set packet_size_ 1024
        $cbr set rate_ 32kb 
    # $cbr set random_ false
        $ns at 0.5 "$cbr start"  
    }
}



# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(time) "$node($i) reset"
}

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

