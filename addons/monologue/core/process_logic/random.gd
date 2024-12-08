extends MonologueProcessLogic


func enter(_ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	var outputs: Array = node.get("Outputs", [])
	var random_number: int = randi_range(0, 100)
	var cumulative_weight: int = 0
	
	var next_id: String = ""
	for output in outputs:
		cumulative_weight += output.get("Weight")
		if random_number <= cumulative_weight:
			next_id = output.get("NextID")
	
	return MonologueProcessResult.continue_process(node.get("NextID"))
