class_name TurretInfoPanel extends Panel

signal upgrade_requested(coords: Vector2i)
signal sell_requested(coords: Vector2i)

# UI References
@onready var title_label: Label = %TitleLabel
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var damage_label: Label = %DamageLabel
@onready var range_label: Label = %RangeLabel
@onready var fire_rate_label: Label = %FireRateLabel

@onready var upgrade_button: Button = %UpgradeButton
@onready var upgrade_cost_label: Label = %UpgradeCostLabel
@onready var sell_button: Button = %SellButton
@onready var sell_refund_label: Label = %SellRefundLabel
@onready var close_button: Button = %CloseButton

# State
var current_coords: Vector2i
var current_turret: Turret = null

func _ready() -> void:
	hide()

	# Connect button signals
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	close_button.pressed.connect(_on_close_pressed)

func show_turret_options(coords: Vector2i, turret: Turret) -> void:
	current_coords = coords
	current_turret = turret

	# Update title with turret type
	var turret_name = _get_turret_name(turret)
	title_label.text = turret_name + " (Lvl " + str(turret.level) + ")"

	# Show and update stats
	stats_container.show()
	if turret.weapon:
		damage_label.text = "Damage: " + str(turret.weapon.stats.damage)
		range_label.text = "Range: " + str(turret.weapon.stats.mob_detection_radius)
		fire_rate_label.text = "Fire Rate: " + str(snapped(turret.weapon.stats.attack_rate, 0.1)) + "/s"

	# Check if upgrade is available
	var upgrade: TurretUpgrade = UpgradeDatabase.get_upgrades_for_weapon(turret.weapon, turret.level)
	if upgrade != null:
		upgrade_button.show()
		upgrade_cost_label.show()
		var upgrade_cost: int = upgrade.cost
		upgrade_cost_label.text = str(upgrade_cost) + " coins"
		upgrade_button.disabled = PlayerUI.coins < upgrade_cost

		# Show upgrade details in button text
		if upgrade.replacement_weapon:
			upgrade_button.text = "Upgrade (New Weapon!)"
		else:
			upgrade_button.text = "Upgrade"
	else:
		upgrade_button.hide()
		upgrade_cost_label.hide()

	# Show sell button with refund amount
	sell_button.show()
	sell_refund_label.show()
	var refund = _calculate_sell_value(turret)
	sell_refund_label.text = "Refund: " + str(refund) + " coins"

	# Position panel near turret
	position_panel_smartly(coords)

	show()

func hide_panel() -> void:
	hide()
	current_coords = Vector2i.ZERO
	current_turret = null

func position_panel_smartly(tile_coords: Vector2i) -> void:
	# Get the grass tilemap from the scene
	var tower_defense = get_tree().current_scene
	if not tower_defense:
		return

	var grass = tower_defense.get_node_or_null("%Grass")
	if not grass:
		return

	# Convert tile coords to world position
	var world_pos = grass.map_to_local(tile_coords)

	# Offset panel to not cover the tile
	var panel_offset = Vector2(120, -100)
	var target_pos = world_pos + panel_offset

	# Clamp to viewport bounds
	var viewport_size = get_viewport_rect().size
	var panel_size = size

	target_pos.x = clampf(target_pos.x, 10, viewport_size.x - panel_size.x - 10)
	target_pos.y = clampf(target_pos.y, 10, viewport_size.y - panel_size.y - 10)

	global_position = target_pos

	# Animate panel appearance
	scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _get_turret_name(turret: Turret) -> String:
	if turret.weapon is SimpleCannon or turret.weapon is SimpleCannonOne:
		return "Simple Cannon"
	elif turret.weapon is MediumCannon:
		return "Medium Cannon"
	elif turret.weapon is RocketLauncher:
		return "Rocket Launcher"
	else:
		return "Turret"

func _calculate_sell_value(turret: Turret) -> int:
	const BASE_COST = 100
	const UPGRADE_BASE_COST = 100
	const REFUND_PERCENT = 0.7

	var total_cost = BASE_COST

	# Add upgrade costs (simplified - each level costs 100)
	if turret.level > 1:
		total_cost += (turret.level - 1) * UPGRADE_BASE_COST

	return int(total_cost * REFUND_PERCENT)

# Button callbacks
func _on_upgrade_pressed() -> void:
	upgrade_requested.emit(current_coords)

func _on_sell_pressed() -> void:
	sell_requested.emit(current_coords)

func _on_close_pressed() -> void:
	hide_panel()

# Handle ESC key to close panel
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		hide_panel()
		get_viewport().set_input_as_handled()
