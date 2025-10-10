extends Area2D

@export var max_distance:= 1000.0
@onready var distance:= 0.0
@export  var speed:= 350
@export var damage:= 20.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitorable = false
	z_as_relative = false

func _physics_process(delta: float) -> void:
	if distance <= max_distance:
		position += transform.x  * delta * speed
		distance += delta * speed
	else:
		explode()

func explode():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Mob:
		area.take_damage(damage)
		explode()
