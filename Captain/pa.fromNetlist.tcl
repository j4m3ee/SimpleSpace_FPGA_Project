
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Captain -dir "D:/Work/FPGA Project/Captain/planAhead_run_3" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Work/FPGA Project/Captain/Captain.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Work/FPGA Project/Captain} }
set_property target_constrs_file "Captain.ucf" [current_fileset -constrset]
add_files [list {Captain.ucf}] -fileset [get_property constrset [current_run]]
link_design
