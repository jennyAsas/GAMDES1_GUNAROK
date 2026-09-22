extends CharacterBody2D

@export var move_left_action := "move_left"
@export var move_right_action := "move_right"
@export var jump_action := "move_up"
@export var fast_fall_action := "move_down"
@export var attack_action := "attack"
@export var initial_facing := 1

const SPEED := 220.0
const GRAVITY := 1200.0
const JUMP_VELOCITY := -420.0
const FAST_FALL_GRAVITY_MULT := 2.0
const ATTACK_COOLDOWN_TIME := 0.45
const ATTACK_ACTIVE_TIME := 0.3
const ATTACK_OFFSET := 34.0
const MAX_HEALTH := 100.0
const DAMAGE_PER_HIT := 20.0
const KNOCKBACK_DISTANCE := 30.0
const HITSTUN_TIME := 0.3

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var health_fill: Polygon2D = $HealthBarFill

var start_position: Vector2
var attack_cooldown := 0.0
var health := MAX_HEALTH
var invulnerable := false
var is_attacking := false
var is_ko := false
var facing := 1.0

func _ready() -> void:
	start_position = position
	facing = float(initial_facing)
	attack_area.position.x = ATTACK_OFFSET * facing
	attack_shape.disabled = true
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_update_health_bar()
	_update_facing_visual()

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		var gravity_mult := FAST_FALL_GRAVITY_MULT if Input.is_action_pressed(fast_fall_action) else 1.0
		velocity.y += GRAVITY * gravity_mult * delta

	if is_on_floor() and Input.is_action_just_pressed(jump_action):
		velocity.y = JUMP_VELOCITY

	var horizontal := Input.get_axis(move_left_action, move_right_action)
	velocity.x = horizontal * SPEED
	move_and_slide()

	position.x = clamp(position.x, 16, get_viewport_rect().size.x - 16)

	if horizontal != 0.0:
		facing = signf(horizontal)
		attack_area.position.x = ATTACK_OFFSET * facing
		_update_facing_visual()

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if Input.is_action_just_pressed(attack_action) and attack_cooldown <= 0.0:
		_do_attack()

	_update_animation(horizontal)

func _update_facing_visual() -> void:
	sprite.flip_h = facing < 0.0

func _update_animation(horizontal: float) -> void:
	if is_ko:
		sprite.play("death")
	elif invulnerable:
		sprite.play("hurt")
	elif is_attacking:
		sprite.play("attack")
	elif not is_on_floor():
		sprite.play("jump")
	elif horizontal != 0.0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _do_attack() -> void:
	attack_cooldown = ATTACK_COOLDOWN_TIME
	is_attacking = true
	attack_shape.disabled = false
	await get_tree().create_timer(ATTACK_ACTIVE_TIME).timeout
	attack_shape.disabled = true
	is_attacking = false

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
		is_ko = true
		await get_tree().create_timer(0.4).timeout
		_ko_reset_all()

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(4, 4, 4, 1), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.05)

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
	velocity = Vector2.ZERO
	attack_cooldown = 0.0
	is_attacking = false
	is_ko = false
	invulnerable = false
	attack_shape.disabled = true
	sprite.modulate = Color(1, 1, 1, 1)
	facing = float(initial_facing)
	attack_area.position.x = ATTACK_OFFSET * facing
	_update_facing_visual()
	_update_health_bar()
