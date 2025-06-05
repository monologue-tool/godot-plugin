class_name MonologueCharacterDisplayer extends Control


@onready var left: TextureRect = %TextureLeft
@onready var center: TextureRect = %TextureCenter
@onready var right: TextureRect = %TextureRight

var left_character_idx: int = -1
var center_character_idx: int = -1
var right_character_idx: int = -1

var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR
var ease_type: Tween.EaseType = Tween.EASE_IN_OUT


func set_filter(filter: MonologueProcessSettings.TextureFilter) -> void:
	left.texture_filter = filter as CanvasItem.TextureFilter
	center.texture_filter = filter as CanvasItem.TextureFilter
	right.texture_filter = filter as CanvasItem.TextureFilter


func set_interpolation_type(interpolation: MonologueProcessSettings.InterpolationType) -> void:
	transition_type = interpolation as Tween.TransitionType


func set_ease_type(ease: MonologueProcessSettings.EaseType) -> void:
	ease_type = ease as Tween.EaseType


func set_texture(texture: Array, character_idx: int, mirror: bool = false,
				 slot_pos: String = "Left", animation_name: String = "None",
				 duration: float = 0.5, fps: float = 12.0) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	slot.flip_h = mirror
	_set_animated_texture(texture, slot_pos, fps)
	_set_character_idx(slot_pos, character_idx)
	
	run_animation(slot_pos, animation_name, duration)


func focus_slot(slot_pos: String) -> void:
	for slot: TextureRect in [left, center, right]:
		slot.modulate.v = 0.5
	
	var focus_slot: TextureRect = _get_slot(slot_pos)
	if focus_slot:
		focus_slot.modulate.v = 1.0


func _set_animated_texture(textures: Array, slot_pos: String = "Left", fps: float = 12.0) -> void:
	var as_slot: AnimatedSprite2D = _get_slot_animated_sprite(slot_pos)
	var sv_slot: SubViewport = _get_slot_subviewport(slot_pos)
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	sprite_frames.set_animation_speed("default", fps)
	sv_slot.size = textures[0].get_image().get_size()
	
	
	for frame in textures:
		sprite_frames.add_frame("default", frame, 1.0)
	as_slot.sprite_frames = sprite_frames
	as_slot.animation = "default"
	as_slot.play("default")


func _process(_delta: float) -> void:
	return
	for slot in [left, center, right]:
		if slot.texture is AnimatedTexture:
			if slot.texture.current_frame + 1 >= slot.texture.frames:
				slot.texture.current_frame = 0
			else:
				slot.texture.current_frame += 1


func run_animation(slot_pos: String = "Left", animation_name: String = "None", 
				   duration: float = 0.5) -> void:
	var func_anim: Callable
	
	match animation_name:
		"None": return
		"Default": return
		"Fade In": _animation_fade_in
		"Fade Out": _animation_fade_in
		"Slide In Auto":
			match slot_pos:
				"Left": func_anim = _animation_slide_in_left
				"Center": func_anim = _animation_slide_in_left
				"Right": func_anim = _animation_slide_in_right
		"Slide In Down": func_anim = _animation_slide_in_down
		"Slide In Left": func_anim = _animation_slide_in_left
		"Slide In Right": func_anim = _animation_slide_in_right
		"Slide In Up": func_anim = _animation_slide_in_up
		"Slide Out Auto":
			match slot_pos:
				"Left": func_anim = _animation_slide_out_left
				"Center": func_anim = _animation_slide_out_left
				"Right": func_anim = _animation_slide_out_right
		"Slide Out Down": func_anim = _animation_slide_out_down
		"Slide Out Left": func_anim = _animation_slide_out_left
		"Slide Out Right": func_anim = _animation_slide_out_right
		"Slide Out Up": func_anim = _animation_slide_out_up
		"Bounce": func_anim = _animation_bounce
		"Shake": func_anim = _animation_shake
	
	if not func_anim: return
	func_anim.bind(slot_pos, duration).call_deferred()


func _animation_fade_in(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	
	slot.modulate.a = 0
	await tween.tween_property(slot, "modulate:a", 1.0, duration)


func _animation_fade_out(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	
	slot.modulate.a = 1.0
	await tween.tween_property(slot, "modulate:a", 0.0, duration)


func _animation_slide_in_down(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(slot_position.x, size.y))
	
	await tween.tween_property(slot, "position", slot_position, duration)


func _animation_slide_in_left(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(-slot.size.x, slot_position.y))
	
	await tween.tween_property(slot, "position", slot_position, duration)


func _animation_slide_in_right(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(size.x, slot_position.y))
	
	await tween.tween_property(slot, "position", slot_position, duration)


func _animation_slide_in_up(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(slot_position.x, -size.y))


func _animation_slide_out_down(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 = Vector2(slot_position.x, size.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_slide_out_left(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 =  Vector2(-slot.size.x, slot_position.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_slide_out_right(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 =  Vector2(size.x, slot_position.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_slide_out_up(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 = Vector2(slot_position.x, -size.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_bounce(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween().set_parallel(true)
	var slot_position: Vector2 = slot.position
	var target_y_position: float = size.y - slot.size.y * 0.9
	
	tween.tween_property(slot, "scale:y", 0.9, duration/2)
	tween.tween_property(slot, "position:y", target_y_position, duration/2)
	tween = tween.chain()
	tween.tween_property(slot, "scale:y", 1.0, duration/2)
	tween.tween_property(slot, "position", slot_position, duration/2)
	await tween.finished
	


func _animation_shake(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = invoke_tween()
	var slot_position: Vector2 = slot.position
	
	var shake: int = 10
	var shake_count: float = duration/0.05

	for i in range(int(shake_count)-1):
		var target_position: Vector2 = slot_position + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
		await tween.tween_property(slot, "position", target_position, 0.05)
	
	await tween.tween_property(slot, "position", slot_position, 0.05)


func _get_slot(slot: String) -> Variant:
	match slot:
		"Left": return left
		"Center": return center
		"Right": return right
	return


func _set_character_idx(slot: String, character_idx: int) -> void:
	match slot:
		"Left": left_character_idx = character_idx
		"Center": center_character_idx = character_idx
		"Right": right_character_idx = character_idx


func get_slot_name_from_character_idx(character_idx: int) -> Variant:
	match character_idx:
		left_character_idx: return "Left"
		center_character_idx: return "Center"
		right_character_idx: return "Right"
	return null


func _get_slot_subviewport(slot: String) -> SubViewport:
	match slot:
		"Left": return %LeftSubViewport
		"Center": return %CenterSubViewport
		"Right": return %RightSubViewport
	return %LeftSubViewport


func _get_slot_animated_sprite(slot: String) -> AnimatedSprite2D:
	match slot:
		"Left": return %LeftAnimatedSprite2D
		"Center": return %CenterAnimatedSprite2D
		"Right": return %RightAnimatedSprite2D
	return %LeftAnimatedSprite2D


func invoke_tween() -> Tween:
	var tween: Tween = create_tween()
	tween.set_trans(transition_type)
	tween.set_ease(ease_type)
	return tween
