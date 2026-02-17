extends Node2D

# --- UI REFERENZEN ---
@onready var background = %Background
@onready var goldLabel = %GoldLabel
@onready var dayLabel = %DayLabel
@onready var blackOverlay = %BlackOverlay # Unser neuer Vorhang

@onready var btnArena = %BtnArena
@onready var btnShop = %BtnShop
@onready var btnArmory = %BtnArmory
@onready var btnTavern = %BtnTavern

# --- BILDER LADEN ---
var img_day = preload("res://assets/sprites/bg_image.jpg") # Dein Tag-Bild
var img_night = preload("res://assets/sprites/bg_image_night.jpg") # Dein neues Nacht-Bild

func _ready():
	update_ui()
	
func update_ui():

	# 3. Tageszeit prüfen und Stadt aufbauen
	if GameManager.is_night:
		setup_night()
	else:
		setup_day()
	
func setup_day():
	background.texture = img_day
	
	# Alles geöffnet
	btnArena.visible = true
	btnShop.visible = true
	btnArmory.visible = true
	

func setup_night():
	background.texture = img_night
	
	# Bei Nacht hat alles zu (außer die Taverne!)
	btnArena.visible = false
	btnShop.visible = false
	btnArmory.visible = false
	
	
# Diese Funktionen erstellen wir gleich über Signale
func _on_btn_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
	
	
func _on_btn_armory_pressed():
	#TODO Logik, Tag hochzählen etc.
	GameManager.change_scene("res://scenes/armory.tscn")
	
	
func _on_btn_arena_pressed():
	#TODO Logik, Tag hochzählen etc.
	GameManager.change_scene("res://scenes/arena_prep.tscn")


func _on_btn_tavern_pressed():
	GameManager.change_scene("res://scenes/tavern.tscn")
