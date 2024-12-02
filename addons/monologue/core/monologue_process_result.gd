class_name MonologueProcessResult extends RefCounted


enum TYPE {
	CONTINUE,
	INTERRUPT,
	EXIT
}

var type: TYPE = TYPE.CONTINUE
var data: Dictionary = {}


static func continue_process(next_node_id: String) -> MonologueProcessResult:
	var result := MonologueProcessResult.new()
	result.type = TYPE.CONTINUE
	result.data["next_node_id"] = next_node_id
	return result


static func interrupt_process(next_node_id: String) -> MonologueProcessResult:
	var result := MonologueProcessResult.new()
	result.type = TYPE.INTERRUPT
	result.data["next_node_id"] = next_node_id
	return result


static func exit_process(reason: String = "") -> MonologueProcessResult:
	var result := MonologueProcessResult.new()
	result.type = TYPE.EXIT
	result.data["reason"] = reason
	return result
