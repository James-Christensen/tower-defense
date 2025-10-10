extends Node2D
@onready var mob: Mob = $Mob
@onready var homing_rocket: Area2D = $HomingRocket



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	homing_rocket.target = mob


func _process(_delta: float) -> void:
	if mob:
		mob.global_position = get_global_mouse_position()
