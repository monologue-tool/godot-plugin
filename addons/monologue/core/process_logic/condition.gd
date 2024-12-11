class_name MonologueConditionLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var variable: Dictionary = ctx.variables.get(node.get("Variable"))
	var operator: String = node.get("Operator")
	var condition_value: Variant = node.get("Value")
	var variable_value: Variant = variable.get("Value")
	var if_nid: String = node.get("IfNextID")
	var else_nid: String = node.get("ElseNextID")
	
	var next_id: String = ""
	match operator:
		"==": next_id = if_nid if variable_value == condition_value else else_nid
		">=": next_id = if_nid if variable_value >= condition_value else else_nid
		"<=": next_id = if_nid if variable_value <= condition_value else else_nid
		"!=": next_id = if_nid if variable_value != condition_value else else_nid
		_: next_id = else_nid
	
	return MonologueProcessResult.continue_process(next_id)
