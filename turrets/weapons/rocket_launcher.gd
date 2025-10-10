class_name RocketLauncher extends Weapon

@onready var _marker_2d: Marker2D = %Marker2D
var _target: Mob = null

func _physics_process(_delta: float) -> void:
	if _target == null:
		_target = _find_closest_target()

	if _target != null:
		look_at(_target.global_position)

func attack() -> void:
	if _target == null:
		return

	var rocket: Area2D = preload("projectiles/homing_rocket.tscn").instantiate()
	get_tree().current_scene.add_child(rocket)
	rocket.global_transform = _marker_2d.global_transform
	
	rocket.target = _target
	rocket.damage = stats.damage
