
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name Captain -dir "D:/Work/FPGA Project/SimpleSpace/Captain/planAhead_run_3" -part xc6slx9tqg144-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "Captain.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {BCD_7SEG.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Captain.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top Captain $srcset
add_files [list {Captain.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-3
