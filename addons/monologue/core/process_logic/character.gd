class_name MonologueCharacterLogic extends MonologueProcessLogic


var left_slot: int
var center_slot: int
var right_slot: int


func enter(ctx: MonologueContext, node: Dictionary, _data: Dictionary = {}) -> MonologueProcessResult:
	var character_idx: int = node.get("Character", -1)
	var action_type: String = node.get("ActionType", "Join")
	
	var process_result := MonologueProcessResult.continue_process(node.get("NextID"))
	
	match action_type:
		"Join", "Update":
			var portrait_name: String = node.get("Portrait", "")
			var position: String = node.get("Position", "Left")
			var animation: String = node.get("JoinAnimation", node.get("UpdateAnimation", "None"))
			var duration: float = node.get("Duration", 0.5)
			var mirror: bool = node.get("Mirrored", false)
			var texture_id = "%s_%s" % [character_idx, portrait_name]
			
			var portrait_res := ctx.images.get_resource(texture_id)
			var portrait_meta: Dictionary = ctx.images.get_resource_meta(texture_id)
			if portrait_res == null:
				return process_result
			
			var textures: Array = []
			if portrait_res is not Array:
				textures = [portrait_res]
			else:
				textures = portrait_res
			ctx.timeline.character_displayer.set_texture(textures, character_idx, mirror, position, animation, duration, portrait_meta.get("Fps", 12.0))
		"Leave":
			pass
	
	return process_result
