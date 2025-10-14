class_name TurretShopPanel extends Panel

signal turret_selected(turret_data: Dictionary)
signal shop_closed

@onready var turret_list_container: VBoxContainer = %TurretListContainer
@onready var close_button: Button = %CloseButton

var turret_buttons: Array[Button] = []

func _ready() -> void:
	hide()
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func populate_shop(turret_catalog: Array[Dictionary]) -> void:
	# Clear existing buttons
	for child in turret_list_container.get_children():
		child.queue_free()
	turret_buttons.clear()

	# Create button for each turret type
	for turret_data in turret_catalog:
		var turret_button = create_turret_button(turret_data)
		turret_list_container.add_child(turret_button)
		turret_buttons.append(turret_button)

func create_turret_button(turret_data: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 80)

	# Create button content
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 12)

	# Icon
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.texture = turret_data.get("icon")
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(icon)

	# Text info
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = turret_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 1)
	vbox.add_child(name_label)

	var cost_label = Label.new()
	cost_label.text = str(turret_data.get("cost", 0)) + " coins"
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(0.9758175, 0.761688, 0.9661009, 0.7607843))
	cost_label.add_theme_color_override("font_outline_color", Color.BLACK)
	cost_label.add_theme_constant_override("outline_size", 1)
	vbox.add_child(cost_label)

	hbox.add_child(vbox)
	button.add_child(hbox)

	# Connect signal
	button.pressed.connect(_on_turret_button_pressed.bind(turret_data))

	# Store turret_data reference for later access
	button.set_meta("turret_data", turret_data)

	return button

func show_shop() -> void:
	show()
	update_affordability()

	# Animate appearance
	scale = Vector2(0.9, 0.9)
	modulate.a = 0.0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func hide_shop() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.finished.connect(hide)

func update_affordability() -> void:
	var current_coins = PlayerUI.coins

	for button in turret_buttons:
		if button.has_meta("turret_data"):
			var turret_data: Dictionary = button.get_meta("turret_data")
			var cost: int = turret_data.get("cost", 0)
			button.disabled = current_coins < cost

func _on_turret_button_pressed(turret_data: Dictionary) -> void:
	turret_selected.emit(turret_data)
	hide_shop()

func _on_close_pressed() -> void:
	shop_closed.emit()
	hide_shop()

# Handle ESC key to close shop
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		shop_closed.emit()
		hide_shop()
		get_viewport().set_input_as_handled()
