extends Node
const LEVEL_1 = preload("uid://jbcpr0nyfo72")
const LEVEL_2 = preload("uid://dtjncf7kuwh04")
const LEVEL_3 = preload("uid://du5l55g0qo8ul")


const ROCKET_LAUNCHER = preload("uid://sc5sxy7vmdc7")

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
