extends MonologueProcessLogic


func process(_ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	return MonologueProcessResult.continue_process(node.get("NextID"))
