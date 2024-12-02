class_name MonologueProcessLogic extends RefCounted


func process(_ctx: MonologueContext, _node: Dictionary) -> MonologueProcessResult:
	return MonologueProcessResult.exit_process("Empty process")
