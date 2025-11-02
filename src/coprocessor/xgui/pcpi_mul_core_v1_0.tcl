# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.COUNT { PARAM_VALUE.COUNT } {
	# Procedure called to update COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNT { PARAM_VALUE.COUNT } {
	# Procedure called to validate COUNT
	return true
}

proc update_PARAM_VALUE.READ_BASE { PARAM_VALUE.READ_BASE } {
	# Procedure called to update READ_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_BASE { PARAM_VALUE.READ_BASE } {
	# Procedure called to validate READ_BASE
	return true
}

proc update_PARAM_VALUE.WRITE_BASE { PARAM_VALUE.WRITE_BASE } {
	# Procedure called to update WRITE_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_BASE { PARAM_VALUE.WRITE_BASE } {
	# Procedure called to validate WRITE_BASE
	return true
}


proc update_MODELPARAM_VALUE.READ_BASE { MODELPARAM_VALUE.READ_BASE PARAM_VALUE.READ_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_BASE}] ${MODELPARAM_VALUE.READ_BASE}
}

proc update_MODELPARAM_VALUE.WRITE_BASE { MODELPARAM_VALUE.WRITE_BASE PARAM_VALUE.WRITE_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_BASE}] ${MODELPARAM_VALUE.WRITE_BASE}
}

proc update_MODELPARAM_VALUE.COUNT { MODELPARAM_VALUE.COUNT PARAM_VALUE.COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNT}] ${MODELPARAM_VALUE.COUNT}
}

