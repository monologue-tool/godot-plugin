class_name MonologueEndPathLogic extends MonologueProcessLogic


func enter(_ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	return MonologueProcessResult.exit_process()
