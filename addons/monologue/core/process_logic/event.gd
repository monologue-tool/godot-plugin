class_name MonologueEventLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, data: Dictionary = {}) -> MonologueProcessResult:
	var fallback_id := data.get("fallback_id")
	ctx.timeline.fallback_id_stack.push_front(fallback_id)
	
	return MonologueProcessResult.continue_process(node.get("NextID"))


func active_update(ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	if not is_instance_valid(ctx.timeline) or node == ctx.timeline.current_node:
		return
	
	if node.get("Triggered", false):
		return
	
	var variable: Dictionary = ctx.variables.get(node.get("Variable"))
	var operator: String = node.get("Operator")
	var condition_value: Variant = node.get("Value")
	var variable_value: Variant = variable.get("Value")
	
	var trigger_event: bool = false
	match operator:
		"==": trigger_event = variable_value == condition_value
		"=": trigger_event = variable_value == condition_value # FIXME: Monologue issue
		">=": trigger_event = variable_value >= condition_value
		"<=": trigger_event = variable_value <= condition_value
		"!=": trigger_event = variable_value != condition_value
	
	if trigger_event:
		var node_idx = ctx.timeline.node_list.find(node)
		ctx.timeline.node_list[node_idx]["Triggered"] = true
		
		var process_result := MonologueProcessResult.continue_process(node.get("ID"))
		process_result.data["fallback_id"] = ctx.timeline.current_node.get("ID")
		
		return process_result
	return MonologueProcessResult.none()
