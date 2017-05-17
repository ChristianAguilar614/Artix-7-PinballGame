# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.cache/wt} [current_project]
set_property parent.project_path {Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.xpr} [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo {z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files -quiet {{Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/sources_1/ip/framebuffer/framebuffer.dcp}}
set_property used_in_implementation false [get_files {{Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/sources_1/ip/framebuffer/framebuffer.dcp}}]
read_verilog -library xil_defaultlib {
  {Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/sources_1/new/board.v}
  {Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/sources_1/new/vga_timing.v}
  {Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/sources_1/new/linedraw.v}
  {Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/sources_1/new/game_display.v}
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc {{Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/constrs_1/new/game_display.xdc}}
set_property used_in_implementation false [get_files {{Z:/Documents/School/SJSU/EE 178/Pinball/final_pinball.srcs/constrs_1/new/game_display.xdc}}]


synth_design -top game_display -part xc7a35tcpg236-1


write_checkpoint -force -noxdef game_display.dcp

catch { report_utilization -file game_display_utilization_synth.rpt -pb game_display_utilization_synth.pb }