extends CharacterBody2D

const SPEED := 250.0

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	velocity = input_dir * SPEED
	move_and_slide()

	if input_dir != Vector2.ZERO:
		rotation = lerp_angle(rotation, input_dir.x * 0.15, 0.2)
		$Polygon2D.scale = $Polygon2D.scale.lerp(Vector2(1.15, 0.85), 0.2)
		if $MoveSound.stream and not $MoveSound.playing:
			$MoveSound.play()
	else:
		rotation = lerp_angle(rotation, 0.0, 0.2)
		$Polygon2D.scale = $Polygon2D.scale.lerp(Vector2.ONE, 0.2)
		if $MoveSound.playing:
			$MoveSound.stop()

	var viewport_size := get_viewport_rect().size
	position.x = clamp(position.x, 16, viewport_size.x - 16)
	position.y = clamp(position.y, 16, viewport_size.y - 16)
