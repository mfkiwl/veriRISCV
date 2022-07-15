# ---------------------------------------------------------------
# Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
# Author: Heqing Huang
# Date Created: 07/14/2022
# ---------------------------------------------------------------
# Tcl Script for Quartus STA
# ---------------------------------------------------------------

# ------------------------------------------
# Open project and read in rtl files
# ------------------------------------------

set QUARTUS_PART        $::env(QUARTUS_PART)
set QUARTUS_FAMILY      $::env(QUARTUS_FAMILY)
set QUARTUS_PRJ         $::env(QUARTUS_PRJ)
set QUARTUS_TOP         $::env(QUARTUS_TOP)
set QUARTUS_VERILOG     $::env(QUARTUS_VERILOG)
set QUARTUS_SEARCH      $::env(QUARTUS_SEARCH)
set QUARTUS_SDC         $::env(QUARTUS_SDC)
set QUARTUS_QIP         $::env(QUARTUS_QIP)
set QUARTUS_PIN         $::env(QUARTUS_PIN)
set QUARTUS_DEFINE      $::env(QUARTUS_DEFINE)

package require ::quartus::project
project_open -revision $QUARTUS_PRJ $QUARTUS_PRJ

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY [pwd]
export_assignments

# ------------------------------------------
# Run STA
# ------------------------------------------

package require ::quartus::sta

# Always create the netlist first
create_timing_netlist
# Read in SDC
if { [llength $QUARTUS_SDC] > 0 } {
    foreach sdc $QUARTUS_SDC {
        read_sdc $sdc
    }
}
update_timing_netlist

set timing_file "timing.rpt"
# Run a setup analysis between nodes "foo" and "bar",
# reporting the worst-case slack if a path is found.
report_clocks -file $timing_file
create_timing_summary -panel_name "Setup Summary" -file $timing_file -append
create_timing_summary -hold -panel_name "Hold Summary" -file $timing_file -append
report_timing -to_clock { clk } -setup -npaths 10 -detail full_path -panel_name {Setup: clk} -file $timing_file -append
