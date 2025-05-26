class_name MonologueChoiceLogic extends MonologueProcessLogic


func _ready() -> void:
	clear_text_box = false


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	for opt_id in node.get("OptionsID"):
		var option_node = ctx.options.get(opt_id)
		if not option_node["Enable"]:
			continue
		
		var option = ctx.timeline.choice_selector.display_option(option_node, ctx.settings.language)
	
	
	await ctx.timeline.choice_selector.choice_made
	var option: Dictionary = ctx.timeline.choice_selector.last_option
	if option["OneShot"]:
		option["Enable"] = false
	var next_id: String = option.get("NextID")
	
	return MonologueProcessResult.continue_process(next_id)
