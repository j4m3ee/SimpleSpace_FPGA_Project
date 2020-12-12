
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name Energy -dir "D:/Work/FPGA Project/SimpleSpace/Energy/planAhead_run_1" -part xc6slx9tqg144-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "Energy.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {../Captain/BCD_7SEG.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Energy.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top Energy $srcset
add_files [list {Energy.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-3
