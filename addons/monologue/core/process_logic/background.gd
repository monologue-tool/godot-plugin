class_name MonologueBackgroundLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var process_result := MonologueProcessResult.continue_process(node.get("NextID"))
	
	var background_image := ctx.images.get_resource(node.get("ID"))
	if background_image == null:
		return process_result
	ctx.timeline.background.texture = background_image
	
	return process_result
