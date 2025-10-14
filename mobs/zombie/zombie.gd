class_name Zombie extends Mob
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var previous_position: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("walk")
	previous_position = global_position
	super()

func _physics_process(delta: float) -> void:
	# Keep sprite upright regardless of path rotation
	animated_sprite_2d.global_rotation = 0.0

	# Calculate movement direction
	var movement = global_position - previous_position

	# Flip sprite horizontally based on movement direction
	if movement.x > 0:
		animated_sprite_2d.flip_h = false  # Moving right
	elif movement.x <= 0:
		animated_sprite_2d.flip_h = true   # Moving left

	# Update position for next frame
	previous_position = global_position

	# Call parent's physics process (handles health bar rotation)
	super._physics_process(delta)


func take_damage(amount: float, damage_source_position: Vector2 = global_position) ->void:
	set_health(-amount)
	animation_player.play("damage")
	
	# Calculate angle from projectile to mob
	
	# Or for knockback direction:
	var knockback_direction = (global_position - damage_source_position).normalized()
	var knockback_distance = 20.0
	var tween = create_tween()
	tween.tween_property(self, "position", position + knockback_direction * knockback_distance, 0.15)
	
	
	#Animate HP Changes
	if health_tween: 
		health_tween.kill()
	health_tween = get_tree().create_tween()
	health_tween.tween_property(health_bar, "value", current_health, 0.5)

	var damage_indicator: Node2D = preload("res://mobs/damage_indicator.tscn").instantiate()
	get_tree().current_scene.add_child(damage_indicator)
	damage_indicator.global_position = global_position
	damage_indicator.display_amount(amount)

	if current_health <= 0:
		die(true)

func die(was_killed := false) -> void:
	speed = 0.0  # Stop movement along path
	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished

	if was_killed:
		for current_index: int in coins:
			var coin: Node2D = preload("res://autoload/coin.tscn").instantiate()
			get_tree().current_scene.add_child.call_deferred(coin)
			coin.global_position = global_position
	queue_free()
