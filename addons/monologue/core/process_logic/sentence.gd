extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	var sentence: String = node.get("Sentence", "")
	var speaker_name: String = node.get("DisplaySpeakerName", "")
	await ctx.display_text(sentence, speaker_name)
	
	return MonologueProcessResult.interrupt_process(node.get("NextID"))


func update(ctx: MonologueContext, node: Dictionary, _delta: float) -> MonologueProcessResult:
	if Input.is_action_just_pressed("ui_continue"):
		if ctx.timeline.text_box.visible_ratio < 1:
			ctx.timeline.text_box.force_display()
	return MonologueProcessResult.none()
