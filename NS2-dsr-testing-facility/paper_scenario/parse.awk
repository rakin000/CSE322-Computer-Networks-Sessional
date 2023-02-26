BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    initial_energy = 100.0; 
    total_energy = 0.0;  
    for(i=0; i<100; i++){ 
       node_energy[i] = initial_energy; 
    } 
 
 
    # constants
    if ( exp_packet_type == "tcp" ) 
	header_bytes = 20 ;
    else header_bytes = 8;
    # print exp_packet_type ;

    print "initial energy :", initial_energy ;
    print "expected packet type:", exp_packet_type ;
    print "header bytes: ", header_bytes ; 
}


{
    event = $1;
    time_sec = $2;
    node = $3;
    layer = $4;
    packet_id = $6;
    packet_type = $7;
    packet_bytes = $8;
    energy_value = $7 ;
    node_id=$5;
    
    sub(/^_*/, "", node);
	sub(/_*$/, "", node);
    # print "Cleaned Node Name: ",node 

    # set start time for the first line
    if(event =="N"){ 
       node_energy[node_id] = energy_value;
       time_sec = $3 ;
    }
    
    if(start_time > time_sec) {
        start_time = time_sec;
    }
    if(end_time < time_sec ) {
        end_time = time_sec ;
    }
   
    if (layer == "AGT" && packet_type == exp_packet_type) {
        
        if(event == "s") {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }
        else if(event == "r") {
            delay = time_sec - sent_time[packet_id];
            total_delay += delay;
            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;  
            received_packets += 1;
        }
    }
    if (packet_type == exp_packet_type && event == "D") {
        dropped_packets += 1;
    }

   
    
}


END {
    end_time = time_sec;
    simulation_time = end_time - start_time;
    throughput = (received_bytes*8)/simulation_time; 
    if( received_packets  ) average_delay = (total_delay/received_packets);
    else average_delay = INF ;
    delivery_ratio = (received_packets/sent_packets);
    drop_ratio = (dropped_packets/sent_packets);

    energy_consumption = 0.0 ;
    for(i=0; i<100; i++) { 
        energy_consumption += initial_energy - node_energy[i]; 
	 # print node_energy[i] ;
    } 

    print "Sent Packets,Dropped Packets,Received Packets,Throughput,Average Delay,Delivery Ratio,Drop Ratio,Energy Consumption";
    print  sent_packets, ",", dropped_packets, ",", received_packets, ",", throughput, ",", average_delay, ",", delivery_ratio, ",", drop_ratio, ",", energy_consumption ; 
   # print "Sent Packets: ", sent_packets;
   # print "Dropped Packets: ", dropped_packets;
   # print "Received Packets: ", received_packets;

   # print "Throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
   #/ print "Average Delay: ", (total_delay / received_packets), "seconds";
   #/ print "Delivery ratio: ", (received_packets / sent_packets);
   #/ print "Drop ratio: ", (dropped_packets / sent_packets);
}
