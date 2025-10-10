extends Node2D
@onready var player_hurt_box: Area2D = %PlayerHurtBox
@onready var grass: TileMapLayer = %Grass
@onready var roads: TileMapLayer = %Roads

@onready var mob_spawner: MobSpawner = $MobSpawner

@onready var game_board:Dictionary = {}
@onready var victory:= false
var mob_spawners: Array[MobSpawner] = []
var spawners_completed: int = 0
var total_spawners: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerUI.health_depleted.connect(game_over)
	PlayerUI.quit_pressed.connect(quit_game)
	PlayerUI.restart_pressed.connect(restart)
	add_roads()

	for current_child: Node in get_children():
		if current_child is MobSpawner:
			mob_spawners.append(current_child)
			current_child.waves_complete.connect(_on_spawner_waves_complete)
			current_child.wave_started.connect(_on_spawner_wave_started)
			current_child.mob_spawned.connect(_on_mob_spawned)
			current_child.mob_died.connect(_on_mob_died)
			var path = roads.find_path_to_target(current_child, player_hurt_box)
			current_child.initialize_path(path)

	total_spawners = mob_spawners.size()
	

func _on_player_hurt_box_area_entered(_area: Area2D) -> void:
	PlayerUI.take_damage(1)


func game_over():
	PlayerUI.player_won(victory)
	PlayerUI.game_over_menu.show()
	get_tree().paused = true
	
func restart() -> void:
	PlayerUI.game_over_menu.hide()
	get_tree().reload_current_scene.call_deferred()
	get_tree().paused = false
	PlayerUI.player_health = 5
	
func quit_game():
	get_tree().quit()
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var turret_coords = grass.local_to_map( event.position)
		request_new_turret(turret_coords)

func add_roads() -> void:
	var occupied = roads.get_used_cells()
	for tile in occupied:
		game_board[tile] = "road"

func _on_spawner_waves_complete() -> void:
	spawners_completed += 1
	if spawners_completed >= total_spawners and PlayerUI.remaining_mobs == 0:
		victory = true
		game_over()

func _on_spawner_wave_started(spawner_index: int, wave_number: int) -> void:
	if spawner_index == 0:
		var message = "Wave: " + str(wave_number) + " Incoming"
		PlayerUI.show_next_wave(message)

func _on_mob_spawned() -> void:
	PlayerUI.remaining_mobs += 1

func _on_mob_died() -> void:
	PlayerUI.remaining_mobs -= 1
	if spawners_completed >= total_spawners and PlayerUI.remaining_mobs == 0:
		victory = true
		game_over()

func request_new_turret(cell_coordinates: Vector2i) -> void:
	if not game_board.has(cell_coordinates):
		const TURRET_COST:= 100
		if PlayerUI.coins <TURRET_COST:
			return
		
		PlayerUI.coins -= TURRET_COST
		place_turret(cell_coordinates)
	elif game_board[cell_coordinates] is Turret:
		request_upgrade_turret(cell_coordinates)
		
func place_turret(coords: Vector2i) -> void:
		var new_turret = Turret.new()
		new_turret.position = grass.map_to_local(coords)
		game_board[coords] = new_turret
		
		add_child(new_turret)
		spawn_stars(new_turret.global_position)
		
func request_upgrade_turret(coords: Vector2i) -> void:
	var turret: Turret = game_board.get(coords)
	var upgrade := UpgradeDatabase.get_upgrades_for_weapon(turret.weapon, turret.level)
	if upgrade != null and upgrade.cost <= PlayerUI.coins:
		PlayerUI.coins -= upgrade.cost
		spawn_stars(turret.global_position)
		upgrade.apply_to_turret(turret)
		
func spawn_stars(target_global_position: Vector2) -> void:
	var stars: GPUParticles2D = preload("res://turrets/upgrades/star_particles.tscn").instantiate()
	add_child(stars)
	stars.global_position = target_global_position
	stars.finished.connect(stars.queue_free)
	stars.restart()
