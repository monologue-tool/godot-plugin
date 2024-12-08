extends MonologueProcessLogic


func enter(_ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	return MonologueProcessResult.exit_process()
