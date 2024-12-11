class_name MonologueChoiceLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	ctx.timeline.text_box.hide()
	for opt_id in node.get("OptionsID"):
		var option_node = ctx.options.get(opt_id)
		if not option_node["Enable"]:
			continue
		
		var option = ctx.timeline.choice_selector.display_option(option_node)
	
	
	await ctx.timeline.choice_selector.choice_made
	var option: Dictionary = ctx.timeline.choice_selector.last_option
	if option["OneShot"]:
		option["Enable"] = false
	var next_id: String = option.get("NextID")
	
	return MonologueProcessResult.continue_process(next_id)
