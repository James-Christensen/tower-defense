extends Control
@onready var heart_container: HBoxContainer = %HBoxContainer

signal health_depleted
signal restart_pressed
signal quit_pressed

@onready var main_label: Label = $GameOverMenu/MarginContainer/VBoxContainer/MainLabel
@onready var next_wave: Label = %NextWave

@onready var remaining_mobs:= 0:
	set(value):
		remaining_mobs = value
		mob_counter.text = "%03d" % remaining_mobs
		
@onready var mob_counter: Label = %MobCounter

@export var player_health:= 5:
	set(value):
		player_health = clampi(value,0,5)
		update_hearts_display()
var hearts: Array[TextureRect] = []

@onready var game_over_menu: Panel = %GameOverMenu

var coins:= 800: set = set_coins
@onready var coin_icon: TextureRect = %CoinIcon
@onready var coin_label: Label = %CoinLabel

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_coins(coins)
	mob_counter.text = "%03d" % remaining_mobs
	game_over_menu.hide()
	for heart in heart_container.get_children():
		hearts.append(heart)


func update_hearts_display():
	for i in hearts.size():
		hearts[i].visible = i < player_health

func take_damage(amount: int):
	player_health -= amount
	if player_health == 0:
		health_depleted.emit()		

func player_won(won: bool):
	if won == true:
		main_label.text = "Victory"
	else:
		main_label.text = "Defeat"
	

func _on_restart_button_pressed() -> void:
	restart_pressed.emit()

func _on_quit_button_pressed() -> void:
	quit_pressed.emit()
	
	
func show_next_wave(message: String):
	next_wave.text = message
	next_wave.show()
	%AnimationPlayer.play("reveal")
	
#Coins
func set_coins(new_coins: int) -> void:
	coins = maxi(0, new_coins)
	if coin_label != null:
		coin_label.text = "%03d" % coins
		
func get_coin_ui_position() -> Vector2:
	return	coin_icon.global_position + coin_icon.size / 2
