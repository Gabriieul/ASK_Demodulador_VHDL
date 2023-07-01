# Artix7 xdc
# define clock and period
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Create a virual clock for IO constraints
create_clock -period 10.000 -name virtual_clock

#output delay
set_output_delay -clock virtual_clock 3.0 [get_ports imag_out]
#set_output_delay -clock virtual_clock -0.5 [get_ports saida_ready]
#set_output_delay -clock virtual_clock -0.5 [get_ports saida_amostra]