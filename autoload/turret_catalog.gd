extends Node

# Preload resources
const SIMPLE_CANNON_WEAPON = preload("res://turrets/weapons/simple_cannon.tscn")
const TURRET_BASE_ICON = preload("res://turrets/turret_base.png")

# Turret catalog - add new turret types here
var catalog: Array[Dictionary] = [
	{
		"id": "simple_cannon",
		"name": "Simple Cannon",
		"cost": 100,
		"range": 200.0,  # Detection radius in pixels
		"icon": TURRET_BASE_ICON,
		"weapon_scene": SIMPLE_CANNON_WEAPON,
		"description": "Basic turret with moderate damage"
	}
	# Future turrets can be added here
	# {
	#     "id": "rapid_fire",
	#     "name": "Rapid Fire",
	#     "cost": 150,
	#     "range": 180.0,
	#     "icon": preload("res://turrets/rapid_fire_icon.png"),
	#     "weapon_scene": preload("res://turrets/weapons/rapid_fire.tscn"),
	#     "description": "Fast firing turret with lower damage"
	# }
]

func get_turret_by_id(id: String) -> Dictionary:
	for turret_data in catalog:
		if turret_data["id"] == id:
			return turret_data
	return {}

func get_all_turrets() -> Array[Dictionary]:
	return catalog

func get_turret_count() -> int:
	return catalog.size()
