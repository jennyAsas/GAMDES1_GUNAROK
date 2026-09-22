extends CharacterBody2D

const SPEED := 220.0
const ATTACK_COOLDOWN_TIME := 0.4
const ATTACK_ACTIVE_TIME := 0.15

@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var body: Polygon2D = $Polygon2D

var start_position: Vector2
var attack_cooldown := 0.0

func _ready() -> void:
	start_position = position
	attack_shape.disabled = true

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	velocity = input_dir * SPEED
	move_and_slide()

	var viewport_size := get_viewport_rect().size
	position.x = clamp(position.x, 16, viewport_size.x - 16)
	position.y = clamp(position.y, 16, viewport_size.y - 16)

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		_do_attack()

func _do_attack() -> void:
	attack_cooldown = ATTACK_COOLDOWN_TIME
	attack_shape.disabled = false
	body.scale = Vector2(1.3, 0.8)
	await get_tree().create_timer(ATTACK_ACTIVE_TIME).timeout
	attack_shape.disabled = true
	body.scale = Vector2.ONE

func reset_round() -> void:
	position = start_position
	attack_cooldown = 0.0
	attack_shape.disabled = true
	body.scale = Vector2.ONE
