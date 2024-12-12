class_name MonologueActionLogic extends MonologueProcessLogic


func enter(_ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var _action: String = node.get("Action")
	var _args: Array = node.get("Arguments")
	
	return MonologueProcessResult.continue_process(node.get("NextID"))
