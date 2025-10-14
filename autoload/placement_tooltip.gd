class_name PlacementTooltip extends Label

## Tooltip that follows cursor during turret placement
## Shows cost and changes color based on affordability

const CURSOR_OFFSET = Vector2(20, 20)  # Offset from cursor to avoid overlap

func _ready() -> void:
	hide()
	# Set default styling
	add_theme_font_size_override("font_size", 18)
	modulate = Color.WHITE

func show_tooltip(cost: int, can_afford: bool) -> void:
	text = str(cost) + " coins"

	# Color code based on affordability
	if can_afford:
		modulate = Color(0.5, 1.0, 0.5)  # Green
	else:
		modulate = Color(1.0, 0.3, 0.3)  # Red

	# Position near cursor
	update_position()
	show()

func update_position() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	global_position = mouse_pos + CURSOR_OFFSET

	# Clamp to viewport bounds to prevent going off-screen
	var viewport_size = get_viewport_rect().size
	global_position.x = clampf(global_position.x, 0, viewport_size.x - size.x - 10)
	global_position.y = clampf(global_position.y, 0, viewport_size.y - size.y - 10)

func hide_tooltip() -> void:
	hide()
