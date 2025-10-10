@icon("res://icons/icon_weapon.svg")
class_name Weapon extends Sprite2D

var stats:= WeaponStats.new() : set = set_stats

var _area_2d := _create_area_2d()
var _collision_shape_2d := _create_collision_shape_2d()
var timer:= create_timer()

func _ready() -> void:
	add_child(_area_2d)
	_area_2d.add_child(_collision_shape_2d)
	
	add_child(timer)
	timer.start()
	timer.timeout.connect(attack)
	
	z_index = 10
	
	set_stats(stats)
	update_from_stats()
	
func _create_area_2d() -> Area2D:
	var area := Area2D.new()
	area.monitoring = true
	area.monitorable = false
	return area

func _create_collision_shape_2d() -> CollisionShape2D:
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	return collision_shape
	
func create_timer() -> Timer:
	var _timer := Timer.new()
	return _timer
	
func attack() -> void:
	return
	
func set_stats(new_stats: WeaponStats)->void:
	if stats != null:
		if stats.changed.is_connected(update_from_stats):
			stats.changed.disconnect(update_from_stats)
	
	stats = new_stats
	if stats != null:
		stats.changed.connect(update_from_stats)
		
func update_from_stats() -> void:
	timer.wait_time = 1.0 / stats.attack_rate
	_collision_shape_2d.shape.radius = stats.mob_detection_radius
