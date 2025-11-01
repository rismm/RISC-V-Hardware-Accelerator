# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DMEM_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DMEM_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IROM_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IROM_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMIO_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.DMEM_BASE { PARAM_VALUE.DMEM_BASE } {
	# Procedure called to update DMEM_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DMEM_BASE { PARAM_VALUE.DMEM_BASE } {
	# Procedure called to validate DMEM_BASE
	return true
}

proc update_PARAM_VALUE.DMEM_DEPTH { PARAM_VALUE.DMEM_DEPTH } {
	# Procedure called to update DMEM_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DMEM_DEPTH { PARAM_VALUE.DMEM_DEPTH } {
	# Procedure called to validate DMEM_DEPTH
	return true
}

proc update_PARAM_VALUE.IROM_BASE { PARAM_VALUE.IROM_BASE } {
	# Procedure called to update IROM_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IROM_BASE { PARAM_VALUE.IROM_BASE } {
	# Procedure called to validate IROM_BASE
	return true
}

proc update_PARAM_VALUE.IROM_DEPTH { PARAM_VALUE.IROM_DEPTH } {
	# Procedure called to update IROM_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IROM_DEPTH { PARAM_VALUE.IROM_DEPTH } {
	# Procedure called to validate IROM_DEPTH
	return true
}

proc update_PARAM_VALUE.MMIO_BASE { PARAM_VALUE.MMIO_BASE } {
	# Procedure called to update MMIO_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMIO_BASE { PARAM_VALUE.MMIO_BASE } {
	# Procedure called to validate MMIO_BASE
	return true
}

proc update_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to update WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to validate WIDTH
	return true
}


proc update_MODELPARAM_VALUE.WIDTH { MODELPARAM_VALUE.WIDTH PARAM_VALUE.WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH}] ${MODELPARAM_VALUE.WIDTH}
}

proc update_MODELPARAM_VALUE.IROM_DEPTH { MODELPARAM_VALUE.IROM_DEPTH PARAM_VALUE.IROM_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IROM_DEPTH}] ${MODELPARAM_VALUE.IROM_DEPTH}
}

proc update_MODELPARAM_VALUE.DMEM_DEPTH { MODELPARAM_VALUE.DMEM_DEPTH PARAM_VALUE.DMEM_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DMEM_DEPTH}] ${MODELPARAM_VALUE.DMEM_DEPTH}
}

proc update_MODELPARAM_VALUE.IROM_BASE { MODELPARAM_VALUE.IROM_BASE PARAM_VALUE.IROM_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IROM_BASE}] ${MODELPARAM_VALUE.IROM_BASE}
}

proc update_MODELPARAM_VALUE.DMEM_BASE { MODELPARAM_VALUE.DMEM_BASE PARAM_VALUE.DMEM_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DMEM_BASE}] ${MODELPARAM_VALUE.DMEM_BASE}
}

proc update_MODELPARAM_VALUE.MMIO_BASE { MODELPARAM_VALUE.MMIO_BASE PARAM_VALUE.MMIO_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMIO_BASE}] ${MODELPARAM_VALUE.MMIO_BASE}
}

