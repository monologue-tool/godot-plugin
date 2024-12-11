class_name MonologueSetterLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var set_type: String = node.get("SetType")
	
	match set_type:
		"Option":
			var option_id: String = node.get("OptionID")
			var value: bool = node.get("Enable") if node.get("Enable") is bool else false
			ctx.options[option_id]["Enable"] = value
		"Variable":
			var variable: Dictionary = ctx.variables.get(node.get("Variable"))
			var operator: String = node.get("Operator")
			var setter_value: Variant = node.get("Value")
			
			match operator:
				"=": variable["Value"] = setter_value
				"+": variable["Value"] += setter_value
				"-": variable["Value"] -= setter_value
				"*": variable["Value"] *= setter_value
				"/":
					if setter_value != 0:
						variable["Value"] /= setter_value
					#else:
						#monologue_notify.emit(NotificationLevel.WARN,
							#"Can't divide %s by 0." % variable.get("Name"))
	
	return MonologueProcessResult.continue_process(node.get("NextID"))
