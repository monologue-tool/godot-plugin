extends MonologueProcessLogic


func process(ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	await ctx.timeline.create_timer(node.get("Time"))
	
	return MonologueProcessResult.continue_process(node.get("NextID"))
