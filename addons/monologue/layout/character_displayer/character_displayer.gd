class_name MonologueCharacterDisplayer extends Control


@onready var left: TextureRect = %TextureLeft
@onready var center: TextureRect = %TextureCenter
@onready var right: TextureRect = %TextureRight


func set_texture(texture: Array, mirror: bool = false,
				 slot_pos: String = "Left", animation_name: String = "None",
				 duration: float = 0.5, fps: float = 12.0) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	slot.flip_h = mirror
	_set_animated_texture(texture, slot_pos, fps)
	
	run_animation(slot_pos, animation_name, duration)


func _set_animated_texture(textures: Array , slot_pos: String = "Left", fps: float = 12.0) -> void:
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
	var tween: Tween = create_tween()
	
	slot.modulate.a = 0
	await tween.tween_property(slot, "modulate:a", 1.0, duration)


func _animation_fade_out(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	
	slot.modulate.a = 1.0
	await tween.tween_property(slot, "modulate:a", 0.0, duration)


func _animation_slide_in_down(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(slot_position.x, size.y))
	
	await tween.tween_property(slot, "position", slot_position, duration)


func _animation_slide_in_left(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(-slot.size.x, slot_position.y))
	
	await tween.tween_property(slot, "position", slot_position, duration)


func _animation_slide_in_right(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(size.x, slot_position.y))
	
	await tween.tween_property(slot, "position", slot_position, duration)


func _animation_slide_in_up(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	slot.set_global_position(Vector2(slot_position.x, -size.y))


func _animation_slide_out_down(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 = Vector2(slot_position.x, size.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_slide_out_left(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 =  Vector2(-slot.size.x, slot_position.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_slide_out_right(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 =  Vector2(size.x, slot_position.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_slide_out_up(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	var target_position: Vector2 = Vector2(slot_position.x, -size.y)
	
	await tween.tween_property(slot, "position", target_position, duration)


func _animation_bounce(slot_pos: String = "Left", duration: float = 0.5) -> void:
	var slot: TextureRect = _get_slot(slot_pos)
	var tween: Tween = create_tween().set_parallel(true)
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
	var tween: Tween = create_tween()
	var slot_position: Vector2 = slot.position
	
	var shake: int = 10
	var shake_count: float = duration/0.05

	for i in range(int(shake_count)-1):
		var target_position: Vector2 = slot_position + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
		await tween.tween_property(slot, "position", target_position, 0.05)
	
	await tween.tween_property(slot, "position", slot_position, 0.05)


func _get_slot(slot: String) -> TextureRect:
	match slot:
		"Left": return left
		"Center": return center
		"Right": return right
	return left


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
