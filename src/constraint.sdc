#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

#create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
#use set derive clock for VGA_NEW_FRAME
#set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  3.000 [get_ports {altera_reserved_tck}]
#set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {altera_reserved_tck}]
#set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  3.000 [get_ports {altera_reserved_tdi}]
#set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {altera_reserved_tdi}]
#set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  3.000 [get_ports {altera_reserved_tms}]
#set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {altera_reserved_tms}]

#set_output_delay -add_delay  -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {altera_reserved_tdo}]

#set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
#set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 

