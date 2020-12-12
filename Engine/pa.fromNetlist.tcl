
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Engine -dir "D:/Work/FPGA Project/SimpleSpace/Engine/planAhead_run_3" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Work/FPGA Project/SimpleSpace/Engine/Engine.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Work/FPGA Project/SimpleSpace/Engine} }
set_property target_constrs_file "Engine.ucf" [current_fileset -constrset]
add_files [list {Engine.ucf}] -fileset [get_property constrset [current_run]]
link_design
