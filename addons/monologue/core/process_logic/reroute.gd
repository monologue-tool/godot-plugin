class_name MonologueRerouteLogic extends MonologueProcessLogic


func enter(_ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	return MonologueProcessResult.continue_process(node.get("NextID"))
