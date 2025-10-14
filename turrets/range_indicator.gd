class_name RangeIndicator extends Node2D

## Visual indicator for turret detection range
## Draws a semi-transparent circle with outline to show turret coverage area

@export var radius: float = 200.0: set = set_radius
@export var fill_color: Color = Color(0.5, 1.0, 0.5, 0.15): set = set_fill_color
@export var outline_color: Color = Color(0.5, 1.0, 0.5, 0.5): set = set_outline_color
@export var outline_width: float = 2.0: set = set_outline_width

func _ready() -> void:
	z_index = -1  # Draw below other sprites

func _draw() -> void:
	# Draw filled circle
	draw_circle(Vector2.ZERO, radius, fill_color)
	# Draw outline circle (using arc for smooth appearance)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, outline_color, outline_width, true)

func set_radius(new_radius: float) -> void:
	radius = new_radius
	queue_redraw()

func set_fill_color(new_color: Color) -> void:
	fill_color = new_color
	queue_redraw()

func set_outline_color(new_color: Color) -> void:
	outline_color = new_color
	queue_redraw()

func set_outline_width(new_width: float) -> void:
	outline_width = new_width
	queue_redraw()

## Update the range indicator with new radius and optional colors
func update_range(new_radius: float, new_fill_color: Color = fill_color, new_outline_color: Color = outline_color) -> void:
	radius = new_radius
	fill_color = new_fill_color
	outline_color = new_outline_color
	queue_redraw()
