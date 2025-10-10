extends Node2D
@onready var mob: Mob = $Mob
@onready var homing_rocket: Area2D = $HomingRocket
@onready var homing_rocket_2: Area2D = $HomingRocket2
@onready var homing_rocket_3: Area2D = $HomingRocket3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	homing_rocket.target = mob
	homing_rocket_2.target = mob
	homing_rocket_3.target = mob

func _process(delta: float) -> void:
	mob.global_position = get_global_mouse_position()
