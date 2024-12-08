extends MonologueProcessLogic


func enter(_ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	return MonologueProcessResult.continue_process(node.get("NextID"))
