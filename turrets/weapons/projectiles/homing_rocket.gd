extends Area2D

var target: Mob = null
var _last_known_position := Vector2.ZERO

@export var max_distance:= 1500.0
@onready var traveled_distance:= 0.0
@export  var speed:= 350
@export var damage:= 20.0


@onready var smoke_trail_particles: GPUParticles2D = $SmokeTrailParticles
@onready var missle_flame: Sprite2D = $MissleFlame
@onready var homing_missle: Sprite2D = $HomingMissle

var velocity := Vector2.ZERO
var drag_factor := 6.0

func _ready() -> void:
	monitorable = false
	z_as_relative = false

	


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
		explode(_last_known_position )

func explode(pos: Vector2):
	
	var explosion: Node2D = preload("res://turrets/weapons/explosion/Explosion.tscn").instantiate()
	explosion.damage = damage
	
	get_tree().current_scene.add_child.call_deferred(explosion)
	explosion.position = pos
	set_deferred("monitoring", false)
	set_physics_process(false)
	homing_missle.hide()
	smoke_trail_particles.emitting = false
	missle_flame.hide()
	
	get_tree().create_timer(0.5).timeout.connect(queue_free)
	
	

func _on_area_entered(_area: Area2D) -> void:
	explode(_last_known_position)
