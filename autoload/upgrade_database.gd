extends Node
const LEVEL_1 = preload("res://turrets/upgrades/level1.tres")
const LEVEL_2 = preload("res://turrets/upgrades/level2.tres")
const LEVEL_3 = preload("res://turrets/upgrades/Level3.tres")
const ROCKET_LAUNCHER = preload("res://turrets/upgrades/rocket_launcher.tres")



func get_upgrades_for_weapon(weapon: Weapon, turret_level: int) -> TurretUpgrade:
	if weapon is SimpleCannon or SimpleCannonOne:
		if turret_level == 1:
			return LEVEL_1
		elif turret_level == 2:
			return LEVEL_2
		elif turret_level == 3:
			return LEVEL_3
		elif turret_level == 4:
			return ROCKET_LAUNCHER
	return null
