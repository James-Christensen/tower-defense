extends Area2D

var damage:= 10.0 

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play()
	animated_sprite_2d.animation_finished.connect(queue_free)
	
	await get_tree().physics_frame
	for area: Area2D in get_overlapping_areas():
		if area is Mob:
			area.take_damage(damage)
