class_name MonologueEndPathLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var next_timeline_path: String = node.get("NextStory", "")
	if not next_timeline_path:
		return MonologueProcessResult.exit_process()
		
	var absolute_path: String = MonologuePathTool.relative_to_absolute(next_timeline_path, ctx.scene_file_path)
	return MonologueProcessResult.exit_process("", absolute_path)
