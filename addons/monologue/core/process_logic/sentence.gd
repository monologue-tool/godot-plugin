extends MonologueProcessLogic


func process(ctx: MonologueContext, node: Dictionary) -> MonologueProcessResult:
	var sentence: String = node.get("Sentence", "")
	var speaker_name: String = node.get("DisplaySpeakerName", "")
	await ctx.display_text(sentence, speaker_name)
	
	return MonologueProcessResult.interrupt_process(node.get("NextID"))
