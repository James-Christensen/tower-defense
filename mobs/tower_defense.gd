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

# Placement system
enum PlacementState { IDLE, PLACING_TURRET }
var current_state := PlacementState.IDLE
var selected_turret_data: Dictionary = {}
var placement_ghost: Sprite2D = null
var placement_range_indicator: RangeIndicator = null

# Selection system
var selected_turret_range_indicator: RangeIndicator = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerUI.health_depleted.connect(game_over)
	PlayerUI.quit_pressed.connect(quit_game)
	PlayerUI.restart_pressed.connect(restart)
	add_roads()

	# Connect shop signals
	PlayerUI.turret_shop.turret_selected.connect(start_turret_placement)
	PlayerUI.turret_shop.shop_closed.connect(_on_shop_closed)

	# Connect turret info panel signals
	PlayerUI.turret_info.upgrade_requested.connect(_on_upgrade_confirmed)
	PlayerUI.turret_info.sell_requested.connect(_on_sell_confirmed)

	# Populate shop with turret catalog
	PlayerUI.turret_shop.populate_shop(TurretCatalog.get_all_turrets())

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
	
func _process(_delta: float) -> void:
	if current_state == PlacementState.PLACING_TURRET and placement_ghost:
		update_placement_ghost()
		# Update tooltip position and affordability
		var cost: int = selected_turret_data.get("cost", 0)
		var can_afford = PlayerUI.coins >= cost
		PlayerUI.placement_tooltip.show_tooltip(cost, can_afford)
		PlayerUI.placement_tooltip.update_position()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if current_state == PlacementState.PLACING_TURRET:
			# Handle placement mode input
			if event.button_index == MOUSE_BUTTON_LEFT:
				attempt_place_turret()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_placement()
		else:
			# Handle normal mode - clicking existing turrets
			if event.button_index == MOUSE_BUTTON_LEFT:
				var turret_coords = grass.local_to_map(event.position)
				if game_board.has(turret_coords) and game_board[turret_coords] is Turret:
					var turret: Turret = game_board[turret_coords]
					PlayerUI.turret_info.show_turret_options(turret_coords, turret)
					show_turret_range(turret)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				# Right-click closes info panel
				PlayerUI.turret_info.hide_panel()
				hide_turret_range()

	# Handle ESC to cancel placement
	if event.is_action_pressed("ui_cancel") and current_state == PlacementState.PLACING_TURRET:
		cancel_placement()
		get_viewport().set_input_as_handled()

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

# Placement system functions
func start_turret_placement(turret_data: Dictionary) -> void:
	# Check affordability
	var cost: int = turret_data.get("cost", 0)
	if PlayerUI.coins < cost:
		return

	current_state = PlacementState.PLACING_TURRET
	selected_turret_data = turret_data

	# Create ghost preview
	create_placement_ghost()

func cancel_placement() -> void:
	current_state = PlacementState.IDLE
	selected_turret_data = {}

	if placement_ghost:
		placement_ghost.queue_free()
		placement_ghost = null

	if placement_range_indicator:
		placement_range_indicator.queue_free()
		placement_range_indicator = null

	# Hide placement tooltip
	PlayerUI.placement_tooltip.hide_tooltip()

func create_placement_ghost() -> void:
	if placement_ghost:
		placement_ghost.queue_free()

	placement_ghost = Sprite2D.new()
	placement_ghost.texture = selected_turret_data.get("icon")
	placement_ghost.modulate = Color(0.5, 1.0, 0.5, 0.6)  # Green tint, semi-transparent
	placement_ghost.z_index = 100
	add_child(placement_ghost)

	# Create range indicator as child of ghost
	if placement_range_indicator:
		placement_range_indicator.queue_free()

	placement_range_indicator = RangeIndicator.new()
	var turret_range: float = selected_turret_data.get("range", 200.0)
	placement_range_indicator.radius = turret_range
	placement_range_indicator.fill_color = Color(0.5, 1.0, 0.5, 0.15)
	placement_range_indicator.outline_color = Color(0.5, 1.0, 0.5, 0.5)
	placement_ghost.add_child(placement_range_indicator)

func update_placement_ghost() -> void:
	if not placement_ghost:
		return

	var mouse_pos = get_global_mouse_position()
	var grid_coords = grass.local_to_map(mouse_pos)
	var snapped_pos = grass.map_to_local(grid_coords)

	placement_ghost.global_position = snapped_pos

	# Update color based on validity and affordability
	var is_valid_tile = validate_placement_tile(grid_coords)
	var cost: int = selected_turret_data.get("cost", 0)
	var can_afford = PlayerUI.coins >= cost

	if not is_valid_tile:
		# Red - invalid tile (road or occupied)
		placement_ghost.modulate = Color(1.0, 0.5, 0.5, 0.6)
		if placement_range_indicator:
			placement_range_indicator.fill_color = Color(1.0, 0.3, 0.3, 0.15)
			placement_range_indicator.outline_color = Color(1.0, 0.3, 0.3, 0.5)
	elif not can_afford:
		# Yellow - valid tile but cannot afford
		placement_ghost.modulate = Color(1.0, 1.0, 0.3, 0.6)
		if placement_range_indicator:
			placement_range_indicator.fill_color = Color(1.0, 1.0, 0.3, 0.15)
			placement_range_indicator.outline_color = Color(1.0, 1.0, 0.3, 0.5)
	else:
		# Green - valid and can afford
		placement_ghost.modulate = Color(0.5, 1.0, 0.5, 0.6)
		if placement_range_indicator:
			placement_range_indicator.fill_color = Color(0.5, 1.0, 0.5, 0.15)
			placement_range_indicator.outline_color = Color(0.5, 1.0, 0.5, 0.5)

func validate_placement_tile(coords: Vector2i) -> bool:
	# Check if tile is already occupied
	if game_board.has(coords):
		return false

	# Check if it's a grass tile (not a road)
	# Roads are in game_board, grass tiles are not
	return true

func attempt_place_turret() -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_coords = grass.local_to_map(mouse_pos)

	if not validate_placement_tile(grid_coords):
		return

	var cost: int = selected_turret_data.get("cost", 0)
	if PlayerUI.coins < cost:
		cancel_placement()
		return

	# Deduct cost and place turret
	PlayerUI.coins -= cost
	place_turret_with_weapon(grid_coords, selected_turret_data)

	# Cancel placement mode
	cancel_placement()

func place_turret_with_weapon(coords: Vector2i, turret_data: Dictionary) -> void:
	var new_turret = Turret.new()
	new_turret.position = grass.map_to_local(coords)

	# Set weapon from turret data
	var weapon_scene = turret_data.get("weapon_scene")
	if weapon_scene:
		new_turret.weapon_scene = weapon_scene

	game_board[coords] = new_turret
	add_child(new_turret)
	spawn_stars(new_turret.global_position)

func _on_shop_closed() -> void:
	# Do nothing, just handle the signal
	pass

# Panel callback handlers
func _on_purchase_confirmed(coords: Vector2i) -> void:
	const TURRET_COST = 100
	if PlayerUI.coins >= TURRET_COST:
		PlayerUI.coins -= TURRET_COST
		place_turret(coords)
		PlayerUI.turret_info.hide_panel()

func _on_upgrade_confirmed(coords: Vector2i) -> void:
	var turret: Turret = game_board.get(coords)
	if turret:
		var upgrade := UpgradeDatabase.get_upgrades_for_weapon(turret.weapon, turret.level)
		if upgrade != null and upgrade.cost <= PlayerUI.coins:
			PlayerUI.coins -= upgrade.cost
			spawn_stars(turret.global_position)
			upgrade.apply_to_turret(turret)
			# Refresh panel to show updated stats and range
			PlayerUI.turret_info.show_turret_options(coords, turret)
			show_turret_range(turret)  # Update range indicator with new stats

func _on_sell_confirmed(coords: Vector2i) -> void:
	sell_turret(coords)

# Legacy function kept for compatibility
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

func sell_turret(coords: Vector2i) -> void:
	var turret: Turret = game_board.get(coords)
	if turret:
		var refund = calculate_sell_value(turret)
		PlayerUI.coins += refund
		spawn_stars(turret.global_position)
		hide_turret_range()  # Clean up range indicator before removing turret
		turret.queue_free()
		game_board.erase(coords)
		PlayerUI.turret_info.hide_panel()

func calculate_sell_value(turret: Turret) -> int:
	const BASE_COST = 100
	const UPGRADE_BASE_COST = 100
	const REFUND_PERCENT = 0.7

	var total_cost = BASE_COST

	# Add upgrade costs based on turret level
	# Each level costs 100 coins (simplified calculation)
	if turret.level > 1:
		total_cost += (turret.level - 1) * UPGRADE_BASE_COST

	return int(total_cost * REFUND_PERCENT)

# Selection range visualization
func show_turret_range(turret: Turret) -> void:
	# Clean up any existing range indicator
	hide_turret_range()

	if turret and turret.weapon:
		selected_turret_range_indicator = RangeIndicator.new()
		var turret_range: float = turret.weapon.stats.mob_detection_radius
		selected_turret_range_indicator.radius = turret_range
		selected_turret_range_indicator.fill_color = Color(0.3, 0.7, 1.0, 0.15)  # Blue tint
		selected_turret_range_indicator.outline_color = Color(0.3, 0.7, 1.0, 0.6)
		turret.add_child(selected_turret_range_indicator)

func hide_turret_range() -> void:
	if selected_turret_range_indicator:
		selected_turret_range_indicator.queue_free()
		selected_turret_range_indicator = null
