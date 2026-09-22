extends CharacterBody2D

const SPEED := 220.0
const MAX_HEALTH := 100.0
const DAMAGE_PER_HIT := 20.0
const KNOCKBACK_DISTANCE := 30.0
const HITSTUN_TIME := 0.3

@onready var hurtbox: Area2D = $Hurtbox
@onready var body: Polygon2D = $Polygon2D
@onready var health_fill: Polygon2D = $HealthBarFill

var health := MAX_HEALTH
var start_position: Vector2
var invulnerable := false

func _ready() -> void:
	start_position = position
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_update_health_bar()

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("p2_left", "p2_right"),
		Input.get_axis("p2_up", "p2_down")
	)
	velocity = input_dir * SPEED
	move_and_slide()

	var viewport_size := get_viewport_rect().size
	position.x = clamp(position.x, 16, viewport_size.x - 16)
	position.y = clamp(position.y, 16, viewport_size.y - 16)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if invulnerable:
		return
	take_damage(DAMAGE_PER_HIT, area.global_position)

func take_damage(amount: float, source_position: Vector2) -> void:
	invulnerable = true
	health = max(health - amount, 0.0)
	_update_health_bar()
	_flash()
	_knockback(source_position)
	await get_tree().create_timer(HITSTUN_TIME).timeout
	invulnerable = false

	if health <= 0.0:
		await get_tree().create_timer(0.4).timeout
		_reset_round()

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(body, "color", Color(1, 1, 1), 0.05)
	tween.tween_property(body, "color", Color(0.9, 0.3, 0.3), 0.05)

func _knockback(source_position: Vector2) -> void:
	var dir := signf(position.x - source_position.x)
	if dir == 0.0:
		dir = 1.0
	var target := position + Vector2(KNOCKBACK_DISTANCE * dir, 0)
	var tween := create_tween()
	tween.tween_property(self, "position", target, 0.1)
	tween.tween_property(self, "position", start_position, 0.2)

func _update_health_bar() -> void:
	health_fill.scale.x = health / MAX_HEALTH

func _reset_round() -> void:
	health = MAX_HEALTH
	position = start_position
	_update_health_bar()
	var p1 := get_node_or_null("../Player1")
	if p1:
		p1.reset_round()
