extends Node

const All_STATS = preload("uid://ntv3w435y7cx")
const DAMAGE = preload("uid://cqksx3ec3nd1r")
const FIRE_RATE= preload("uid://bmy2qw633r5ly")
const RANGE = preload("uid://c2t8ua0s0fmru")

func get_upgrades_for_weapon(weapon: Weapon, turret_level: int) -> TurretUpgrade:
	if weapon is SimpleCannon:
		if turret_level == 1:
			return DAMAGE
		elif turret_level == 2:
			return FIRE_RATE
		elif turret_level == 3:
			return RANGE
		elif turret_level == 4:
			return All_STATS
	return null
