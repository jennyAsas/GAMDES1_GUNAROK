extends CharacterBody2D

@export var move_left_action := "move_left"
@export var move_right_action := "move_right"
@export var move_up_action := "move_up"
@export var move_down_action := "move_down"
@export var attack_action := "attack"
@export var initial_facing := 1

const SPEED := 220.0
const ATTACK_COOLDOWN_TIME := 0.4
const ATTACK_ACTIVE_TIME := 0.15
const ATTACK_OFFSET := 34.0
const MAX_HEALTH := 100.0
const DAMAGE_PER_HIT := 20.0
const KNOCKBACK_DISTANCE := 30.0
const HITSTUN_TIME := 0.3

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var body: Polygon2D = $Polygon2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var health_fill: Polygon2D = $HealthBarFill

var start_position: Vector2
var attack_cooldown := 0.0
var health := MAX_HEALTH
var invulnerable := false
var facing := 1.0

func _ready() -> void:
	start_position = position
	facing = float(initial_facing)
	attack_area.position.x = ATTACK_OFFSET * facing
	attack_shape.disabled = true
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_update_health_bar()

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis(move_left_action, move_right_action),
		Input.get_axis(move_up_action, move_down_action)
	)
	velocity = input_dir * SPEED
	move_and_slide()

	var viewport_size := get_viewport_rect().size
	position.x = clamp(position.x, 16, viewport_size.x - 16)
	position.y = clamp(position.y, 16, viewport_size.y - 16)

	if input_dir.x != 0.0:
		facing = signf(input_dir.x)
		attack_area.position.x = ATTACK_OFFSET * facing

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if Input.is_action_just_pressed(attack_action) and attack_cooldown <= 0.0:
		_do_attack()

func _do_attack() -> void:
	attack_cooldown = ATTACK_COOLDOWN_TIME
	attack_shape.disabled = false
	body.scale = Vector2(1.3, 0.8)
	await get_tree().create_timer(ATTACK_ACTIVE_TIME).timeout
	attack_shape.disabled = true
	body.scale = Vector2.ONE

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if invulnerable:
		return
	if area.get_parent() == self:
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
		_ko_reset_all()

func _flash() -> void:
	var base_color := body.color
	var tween := create_tween()
	tween.tween_property(body, "color", Color(1, 1, 1), 0.05)
	tween.tween_property(body, "color", base_color, 0.05)

func _knockback(source_position: Vector2) -> void:
	var dir := signf(position.x - source_position.x)
	if dir == 0.0:
		dir = -facing
	var target := position + Vector2(KNOCKBACK_DISTANCE * dir, 0)
	var tween := create_tween()
	tween.tween_property(self, "position", target, 0.1)
	tween.tween_property(self, "position", start_position, 0.2)

func _update_health_bar() -> void:
	health_fill.scale.x = health / MAX_HEALTH

func _ko_reset_all() -> void:
	for child in get_parent().get_children():
		if child is CharacterBody2D and child.has_method("reset_round"):
			child.reset_round()

func reset_round() -> void:
	health = MAX_HEALTH
	position = start_position
	attack_cooldown = 0.0
	attack_shape.disabled = true
	body.scale = Vector2.ONE
	facing = float(initial_facing)
	attack_area.position.x = ATTACK_OFFSET * facing
	_update_health_bar()
