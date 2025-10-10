extends Node2D

@onready var label: Label = %Label

func display_amount(amount: int) -> void:
	position.x += randf_range(-32.0, 32.0)
	label.text = str(amount)
