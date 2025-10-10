extends Area2D

var target: Mob = null
var _last_known_position := Vector2.ZERO

@export var max_distance:= 1500.0
@onready var traveled_distance:= 0.0
@export  var speed:= 350
@export var damage:= 50.0

@export var rotation_speed = 1.5
var rotation_direction = 0

var velocity := Vector2.ZERO
var drag_factor := 6.0

func _ready() -> void:
	monitorable = false
	z_as_relative = false
	
	if target:
		print("Target Acquired")
	else:
		print("Target not found")
	


func _physics_process(delta: float) -> void:
	if target != null:
		_last_known_position = target.global_position

	var direction := global_position.direction_to(_last_known_position)
	var desired_velocity:= speed * direction
	var steering_vector := desired_velocity - velocity
	
	velocity += steering_vector * drag_factor * delta
	position += velocity * delta
	rotation = velocity.angle()
	
	traveled_distance += speed * delta
	if (
		traveled_distance > max_distance or
		global_position.distance_to(_last_known_position) < 10.0
	):
		explode()

func explode():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Mob:
		area.take_damage(damage)
		explode()
