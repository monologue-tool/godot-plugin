class_name MonologueAudioLogic extends MonologueProcessLogic


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var loop: bool = node.get("Loop", false)
	var volume: float = node.get("Volume", 0.0) if node.get("Volume") is float else 0.0
	var pitch: float = node.get("Pitch", 1.0) if node.get("Pitch") is float else 1.0
	
	var process_result := MonologueProcessResult.continue_process(node.get("NextID"))
	
	var stream := ctx.audios.get_resource(node.get("ID"))
	if stream == null:
		return process_result
		
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		stream.loop = loop
		
	_play_audio(stream, ctx.timeline, volume, pitch)
	
	return process_result


func _play_audio(audio_stream: AudioStream, player_parent: Node, volume_db: float = 0.0, pitch_scale: float = 1.0, bus: String = "Music") -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player_parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.stream = audio_stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
