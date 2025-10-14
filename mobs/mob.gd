@icon("res://icons/icon_mob.svg")
class_name Mob extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed:= 100.0

@export var max_health:= 100.0
@export var current_health := 100.0 : set = set_health

@onready var bar_pivot: Node2D = %BarPivot
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_tween: Tween = null

@export var coins:= randi_range(3,7)

func set_health(hp_change: float) -> void:
	current_health = clamp(current_health + hp_change, 0, max_health)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func _physics_process(_delta: float) -> void:
	bar_pivot.global_rotation = 0.0
	
func take_damage(amount: float, damage_source_position: Vector2 = global_position) ->void:
	set_health(-amount)
	animation_player.play("damage")
	
	# Calculate angle from projectile to mob
	var hit_angle = global_position.angle_to_point(damage_source_position)
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
	if was_killed:
		for current_index: int in coins:
			var coin: Node2D = preload("res://autoload/coin.tscn").instantiate()
			get_tree().current_scene.add_child.call_deferred(coin)
			coin.global_position = global_position
	queue_free()
