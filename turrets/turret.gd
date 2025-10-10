@tool
class_name Turret extends Sprite2D

@export var weapon_scene: PackedScene = preload("uid://dpa8wqpmoehl3")
const TURRET_BASE = preload("uid://28rkffksa53r")

var weapon: Weapon = null
var level:= 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = TURRET_BASE
	set_weapon_scene(weapon_scene)

func set_weapon_scene(new_scene: PackedScene) -> void:
	weapon_scene = new_scene
	
	if weapon != null:
		weapon.queue_free()
	if weapon_scene != null:
		var weapon_instance:= weapon_scene.instantiate()
		assert(
			weapon_instance is Weapon,
			"The weapon scene must inherit from Weapon"
		)
		if weapon != null:
			weapon_instance.stats = weapon.stats
		add_child(weapon_instance)
		weapon = weapon_instance
