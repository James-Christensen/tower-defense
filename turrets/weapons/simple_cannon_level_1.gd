class_name SimpleCannonOne extends Weapon

@onready var rocket_spawn_point: Marker2D = $RocketSpawnPoint
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _target: Mob = null
var _is_recoiling: bool = false
var _base_position: Vector2

# Add this custom property
@export var recoil_offset: float = 0.0:
	set(value):
		recoil_offset = value
		_apply_recoil()

func _ready() -> void:
	super._ready()
	animation_player.animation_finished.connect(_on_animation_finished)
	_base_position = position

func _apply_recoil() -> void:
	var recoil_direction := Vector2(-recoil_offset, 0).rotated(rotation)
	position = _base_position + recoil_direction


func _physics_process(_delta: float) -> void:
	if _is_recoiling:
		return
		
	if _target == null:
		_target = _find_closest_target()
	if _target != null:
		look_at(_target.global_position)
		_base_position = position  # Update base position after rotation

func attack() -> void:
	var mobs_in_range := _area_2d.get_overlapping_areas()
	if mobs_in_range.is_empty():
		return
	
	_is_recoiling = true
	animation_player.play("attack")
	
	var rocket: Node2D = preload("res://turrets/weapons/projectiles/simple_rocket.tscn").instantiate()
	get_tree().current_scene.add_child(rocket)
	rocket.global_transform = rocket_spawn_point.global_transform
	rocket.damage = stats.damage

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		_is_recoiling = false
