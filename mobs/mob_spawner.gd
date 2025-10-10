class_name MobSpawner
extends Node2D

signal waves_complete
signal wave_complete(wave: String)
signal wave_started(spawner_index: int, wave_number: int)
signal mob_spawned
signal mob_died

@export var mob_packed_scene: PackedScene = preload("mob.tscn")
@export var waves: Array[Wave] = []  # Array of Wave resources
@export var spawner_index: int = 0

var _path:= Path2D.new()
@onready var spawn_timer: Timer = $SpawnTimer

var current_wave_index: int = 0
var mobs_spawned_in_wave: int = 0
var current_wave: Wave

var all_waves_complete:= false

func _ready() -> void:
	_path.child_exiting_tree.connect(_on_child_exiting_tree)
	_path.top_level = true
	add_child(_path)
	_path.curve = Curve2D.new()


	if waves.size() > 0:
		start_wave(0)
		
func initialize_path(points: PackedVector2Array) -> void:
	_path.curve.clear_points()
	for point in points:
		_path.curve.add_point(point)
	
		
		
func start_wave(wave_index: int) -> void:
	if wave_index >= waves.size():
		print("All waves complete!")
		all_waves_complete = true
		waves_complete.emit()
		return
	
	current_wave_index = wave_index
	current_wave = waves[wave_index]
	mobs_spawned_in_wave = 0
	
	spawn_timer.wait_time = current_wave.spawn_rate
	spawn_timer.start()
	wave_started.emit(spawner_index, wave_index + 1)
	#print("Starting Wave ", wave_index + 1)

func spawn_mob() -> void:
	var mob_path_follow := MobPathFollow.new()
	_path.add_child(mob_path_follow)
	
	mob_path_follow.progress = 0.0  #
	# Use wave-specific mob scene if available, otherwise use default
	var scene_to_spawn = current_wave.mob_scene if current_wave.mob_scene else mob_packed_scene
	var mob: Mob = scene_to_spawn.instantiate()
	
	mob_path_follow.add_child(mob)
	mob_path_follow.mob = mob
	mobs_spawned_in_wave += 1
	mob_spawned.emit()

func _on_spawn_timer_timeout() -> void:
	if mobs_spawned_in_wave < current_wave.num_mobs:
		spawn_mob()
	else:
		spawn_timer.stop()
		print("Wave ", current_wave_index + 1, " spawning complete")
		await get_tree().create_timer(current_wave.wave_delay).timeout
		
		start_wave(current_wave_index + 1)


func _on_child_exiting_tree(_node: Node) -> void:
	mob_died.emit()
