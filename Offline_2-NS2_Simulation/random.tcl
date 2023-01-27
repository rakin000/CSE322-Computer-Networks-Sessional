#filename : randtest1.tcl
# Usage: ns randtest.tcl [replication number]
if {$argc > 1} {
    puts "Usage: ns randtest1.tcl \[replication number\]"
    exit
}
set run 1
if {$argc == 1} {
    set run [lindex $argv 0]
}
if {$run < 1} {
    set run 1
}

# seed the default RNG
global defaultRNG
$defaultRNG seed 9999

# # create the RNGs and set them to the correct substream
set arrivaldist [new RNG]
set size [new RNG]
for {set j 1} {$j < $run} {incr j} {
    $arrivaldist next-substream
    $size next-substream
    # puts [format "%d %d" [$arrivaldist] [$size]] 
}

# arrival_ is a exponential random variable describing the time between
# consecutive packet arrivals
set arrival_ [new RandomVariable/Exponential]
$arrival_ set avg_ 5
$arrival_ use-rng $arrivaldist

# size_ is a uniform random variable describing packet sizes
set size_ [new RandomVariable/Uniform]
$size_ set min_ 100
$size_ set max_ 5000
$size_ use-rng $size

# print the first 5 arrival times and sizes
for {set j 0} {$j < 5} {incr j} {
    puts [format "%-8.3f  %-4d" [$arrival_ value] \
            [expr round([$size_ value])]]
}