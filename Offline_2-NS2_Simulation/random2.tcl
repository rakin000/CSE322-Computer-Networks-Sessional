# set n [new RandomVariable/Uniform]
# $n set max_ 500
# $n set min_ 10

# for {set i 1} {$i < 11} {incr i} {
# 	puts "n = [expr round([$n value])]"
# }
# global defaultRNG
# $defaultRNG seed 9999

# set uniform_rnd [new RNG]
set uniform_rnd [new RandomVariable/Uniform]
$uniform_rnd set min_ 100 
$uniform_rnd set max_ 500 
# $uniform_rnd use-rng uniform_rnd 

for {set i 0} {$i < 100} {incr i} {
    puts [expr round([$uniform_rnd value])] 
}

