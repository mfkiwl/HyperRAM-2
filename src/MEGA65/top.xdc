## Signal mapping for MEGA65-R3

#############################################################################################################
# Pin locations and I/O standards
#############################################################################################################

## External clock signal (connected to 100 MHz oscillator)
set_property -dict {PACKAGE_PIN V13  IOSTANDARD LVCMOS33}                                    [get_ports {clk}]

## Reset signal (Active low. From MAX10)
set_property -dict {PACKAGE_PIN M13  IOSTANDARD LVCMOS33}                                    [get_ports {reset_n}]

# HDMI output
set_property -dict {PACKAGE_PIN Y1   IOSTANDARD TMDS_33}  [get_ports {hdmi_clk_n}]
set_property -dict {PACKAGE_PIN W1   IOSTANDARD TMDS_33}  [get_ports {hdmi_clk_p}]
set_property -dict {PACKAGE_PIN AB1  IOSTANDARD TMDS_33}  [get_ports {hdmi_data_n[0]}]
set_property -dict {PACKAGE_PIN AA1  IOSTANDARD TMDS_33}  [get_ports {hdmi_data_p[0]}]
set_property -dict {PACKAGE_PIN AB2  IOSTANDARD TMDS_33}  [get_ports {hdmi_data_n[1]}]
set_property -dict {PACKAGE_PIN AB3  IOSTANDARD TMDS_33}  [get_ports {hdmi_data_p[1]}]
set_property -dict {PACKAGE_PIN AB5  IOSTANDARD TMDS_33}  [get_ports {hdmi_data_n[2]}]
set_property -dict {PACKAGE_PIN AA5  IOSTANDARD TMDS_33}  [get_ports {hdmi_data_p[2]}]

## HyperRAM (connected to IS66WVH8M8BLL-100B1LI, 64 Mbit, 100 MHz, 3.0 V, single-ended clock)
set_property -dict {PACKAGE_PIN B22  IOSTANDARD LVCMOS33  PULLUP FALSE}                      [get_ports {hr_resetn}]
set_property -dict {PACKAGE_PIN C22  IOSTANDARD LVCMOS33  PULLUP FALSE}                      [get_ports {hr_csn}]
set_property -dict {PACKAGE_PIN D22  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_ck}]
set_property -dict {PACKAGE_PIN B21  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_rwds}]
set_property -dict {PACKAGE_PIN A21  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[0]}]
set_property -dict {PACKAGE_PIN D21  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[1]}]
set_property -dict {PACKAGE_PIN C20  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[2]}]
set_property -dict {PACKAGE_PIN A20  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[3]}]
set_property -dict {PACKAGE_PIN B20  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[4]}]
set_property -dict {PACKAGE_PIN A19  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[5]}]
set_property -dict {PACKAGE_PIN E21  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[6]}]
set_property -dict {PACKAGE_PIN E22  IOSTANDARD LVCMOS33  PULLUP FALSE  SLEW FAST  DRIVE 16} [get_ports {hr_dq[7]}]

## Keyboard interface (connected to MAX10)
set_property -dict {PACKAGE_PIN A14  IOSTANDARD LVCMOS33}                                    [get_ports {kb_io0}]
set_property -dict {PACKAGE_PIN A13  IOSTANDARD LVCMOS33}                                    [get_ports {kb_io1}]
set_property -dict {PACKAGE_PIN C13  IOSTANDARD LVCMOS33}                                    [get_ports {kb_io2}]


############################################################################################################
# Clocks
#############################################################################################################

## Primary clock input
create_clock -period 10.000 -name clk [get_ports clk]

## HypeRAM timing
# Rename autogenerated clocks
create_generated_clock -name clk_x2     [get_pins i_clk/i_clk_hyperram/CLKOUT1]
create_generated_clock -name clk_x2_del [get_pins i_clk/i_clk_hyperram/CLKOUT2]
create_generated_clock -name clk_x1     [get_pins i_clk/i_clk_hyperram/CLKOUT3]

# User defined clock
create_generated_clock -name hr_ck -source [get_pins i_clk/i_clk_hyperram/CLKOUT2] -divide_by 2 [get_ports hr_ck]

# Set location (based on closest to I/O pad)
set_property LOC SLICE_X0Y203 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[1]]
set_property LOC SLICE_X0Y203 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[6]]
set_property LOC SLICE_X0Y205 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[7]]
set_property LOC SLICE_X0Y205 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[0]]
set_property LOC SLICE_X0Y207 [get_cells i_system/i_hyperram/i_hyperram_ctrl/hb_rstn_o_reg]
set_property LOC SLICE_X0Y209 [get_cells i_system/i_hyperram/i_hyperram_ctrl/hb_csn_o_reg]
set_property LOC SLICE_X0Y211 [get_cells i_system/i_hyperram/i_hyperram_io/hr_ck_o_reg]
set_property LOC SLICE_X0Y213 [get_cells i_system/i_hyperram/i_hyperram_io/rwds_oe_d_reg]
set_property LOC SLICE_X0Y215 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[2]]
set_property LOC SLICE_X0Y215 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[5]]
set_property LOC SLICE_X0Y217 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[3]]
set_property LOC SLICE_X0Y217 [get_cells i_system/i_hyperram/i_hyperram_io/dq_out_reg[4]]

# From HyperRAM datasheet Table 10.3 (t_CKD)
set tco_min 1.0
set tco_max 7.0
# Board trace (estimate)
set trce_dly 0.5
# Subtract 10 instead of introducing multi-cycle path
# Subtract 5 to account for IDDR falling edge
set_input_delay -clock [get_clocks {hr_ck}] -add_delay -min [expr $tco_min+$trce_dly-15] [get_ports {hr_dq[*]}]
set_input_delay -clock [get_clocks {hr_ck}] -add_delay -max [expr $tco_max+$trce_dly-15] [get_ports {hr_dq[*]}]
set_input_delay -clock [get_clocks {hr_ck}] -add_delay -min [expr $tco_min+$trce_dly-15] [get_ports {hr_rwds}]
set_input_delay -clock [get_clocks {hr_ck}] -add_delay -max [expr $tco_max+$trce_dly-15] [get_ports {hr_rwds}]

#set_false_path -from [get_clocks {hr_ck}] -to [get_clocks {clk_x1}]
#set_false_path -from [get_clocks {hr_ck}] -to [get_clocks {clk_x2}]

## MEGA65 timing
# Rename autogenerated clocks
create_generated_clock -name kbd_clk    [get_pins i_clk_mega65/i_clk_mega65/CLKOUT0]
create_generated_clock -name pixel_clk  [get_pins i_clk_mega65/i_clk_mega65/CLKOUT1]
create_generated_clock -name pixel_clk5 [get_pins i_clk_mega65/i_clk_mega65/CLKOUT2]

# MEGA65 I/O timing is ignored (considered asynchronous)
set_false_path -from [get_ports reset_n]
set_false_path   -to [get_ports hdmi_data_p[*]]
set_false_path   -to [get_ports hdmi_clk_p]
set_false_path   -to [get_ports kb_io0]
set_false_path   -to [get_ports kb_io1]
set_false_path -from [get_ports kb_io2]


#############################################################################################################
# Configuration and Bitstream properties
#############################################################################################################

set_property CONFIG_VOLTAGE                  3.3   [current_design]
set_property CFGBVS                          VCCO  [current_design]
set_property BITSTREAM.GENERAL.COMPRESS      TRUE  [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE     66    [current_design]
set_property CONFIG_MODE                     SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES   [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH   4     [current_design]

