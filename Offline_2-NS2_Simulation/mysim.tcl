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
set val(ifqlen)       50                      ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSR                     ;# ad-hoc routing protocol 
set val(side)         500                      ;# square area. area side    
set val(nn)           40                       ;# number of mobilenodes
set val(nf)           20                        ;# number of flows      
set val(time)         50                        ; # time of simulation 

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
    }

}



# nam file
set nam_file [open mysim_anim.nam w]
$ns namtrace-all-wireless $nam_file $val(side) $val(side)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(side) $val(side)

set uniform_rnd_coord [new RandomVariable/Uniform]
$uniform_rnd_coord set min_ 1
$uniform_rnd_coord set max_ $val(side) 

set uniform_rnd_node [new RandomVariable/Uniform]
$uniform_rnd_node set min_ 0 
$uniform_rnd_node set max_ [expr $val(nn)-1]

# general operation director for mobilenodes
create-god $val(nn)


$ns node-config -adhocRouting $val(rp) \
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

    $node($i) set X_ [expr round([$uniform_rnd_coord value])] 
    $node($i) set Y_ [expr round([$uniform_rnd_coord value])] 
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 20

    # puts [expr $node($i) random-motion]
} 

# set src [expr round([$uniform_rnd_node value])]  
set src [expr int(1000 * rand()) % $val(nn)]
puts "source = $src" 

# set udp [new Agent/UDP]
# set udp_sink [new Agent/Null]
# $ns attach-agent $node($src) $udp

# array set cbr {}
# array set udp {} 
# array set udp_sink {} 

array set taken {} 
for {set index 0} {$index < $val(nn)} {incr index} {
   set taken($index) 0  
}
set taken($src) 1 

for {set i 0} { $i < $val(nf) } {incr i} {
    set dest [expr round([$uniform_rnd_node value])]

    while { $taken($dest) == 1 } {
        set dest [expr round([$uniform_rnd_node value])]
    }
    set taken($dest) 1 
    puts "dest($i) = $dest"
    
    # global cbr udp udp_sink 

    # set udp($i) [new Agent/UDP]
    # $ns attach-agent $node($src) $udp($i) 
    # set udp_sink($i) [new Agent/Null]
    # $ns attach-agent $node($dest) $udp_sink($i)
    # $ns connect $udp($i) $udp_sink($i)
    # $udp($i) set fid_   [expr $i+1] 

    # set cbr($i) [new Application/Traffic/CBR]
    # $cbr($i) attach-agent $udp($i)

    set udp [new Agent/UDP]
    set udp_sink [new Agent/Null]
    $ns attach-agent $node($src) $udp 
    $ns attach-agent $node($dest) $udp_sink
    $ns connect $udp $udp_sink
    $udp set fid_   [expr $i+1] 

    set cbr [new Application/Traffic/CBR]
    $cbr attach-agent $udp
    
    # $cbr set type_ CBR
    # $cbr set packet_size_ 10
    # $cbr set rate_ 0.4mb
    # $cbr set random_ false

    $ns at 0.5 "$cbr start"  
# $ns at [expr int(9 * rand()) + 1] "$cbr start"
}

#  for {set i 0} {$i < $val(nf)} {incr i} {
#     global cbr
#     $ns at 0.5 "$cbr($i) start"  
# }

for {set t 1.0 } {$t < 50 } { set t [expr $t+5] } {
    for {set i 0} {$i < $val(nn) } {incr i} {
        # set nX_ [expr int(rand()*1000)%$val(side) ]
        # set nY_ [expr int(rand()*1000)%$val(side) ]
        # while { $nX_ == [$node($i) X_] && $nY_ == [$node($i) Y_]} {
        #     set nX_ [expr int(rand()*1000)%$val(side) ]
        #     set nY_ [expr int(rand()*1000)%$val(side) ]
        # }
        $ns at $t "$node($i) setdest [expr int(rand()*1000)%$val(side) ] [expr int(rand()*1000)%$val(side) ] 200.0" 
    }
}



for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
    exec nam mysim_anim.nam & 
    exec awk -f parse.awk mysim_trace.tr & 
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at 50.0001 "finish"
$ns at 50.0002 "halt_simulation"




# Run simulation
puts "Simulation starting"
$ns run

