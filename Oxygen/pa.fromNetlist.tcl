
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Oxygen -dir "D:/Work/FPGA Project/SimpleSpace/Oxygen/planAhead_run_3" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Work/FPGA Project/SimpleSpace/Oxygen/Oxygen.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Work/FPGA Project/SimpleSpace/Oxygen} }
set_property target_constrs_file "Oxygen.ucf" [current_fileset -constrset]
add_files [list {Oxygen.ucf}] -fileset [get_property constrset [current_run]]
link_design
