extends Node2D

# --- UI REFERENZEN ---
@onready var background = %Background
@onready var goldLabel = %GoldLabel
@onready var dayLabel = %DayLabel

@onready var btnArena = %BtnArena
@onready var btnShop = %BtnShop
@onready var btnArmory = %BtnArmory
@onready var btnTavern = %BtnTavern

# --- BILDER LADEN ---
var img_day = preload("res://assets/sprites/bg_image.jpg") # Dein Tag-Bild
var img_night = preload("res://assets/sprites/bg_image_night.jpg") # Dein neues Nacht-Bild

func _ready():
	# Wenn die Szene startet, aktualisieren wir die UI mit den Daten aus dem GameManager
	update_ui()
	
func update_ui():
	# Wir greifen auf den globalen GameManager zu
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	dayLabel.text = "Day: " + str(GameManager.currentDay)
	# 3. Tageszeit prüfen und Stadt aufbauen
	if GameManager.is_night:
		setup_night()
	else:
		setup_day()
	
	
	
func setup_day():
	background.texture = img_day
	
	# Alles geöffnet
	btnArena.disabled = false
	btnShop.disabled = false
	btnArmory.disabled = false
	
	btnArena.text = "Enter Arena"
	btnShop.text = "Enter Shop"
	btnArmory.text = "Enter Armory"
	
	if goldLabel:
		goldLabel.add_theme_color_override("font_color", Color.BLACK) 
	if dayLabel:
		dayLabel.add_theme_color_override("font_color", Color.BLACK)

func setup_night():
	background.texture = img_night
	
	# Bei Nacht hat alles zu (außer die Taverne!)
	btnArena.disabled = true
	btnShop.disabled = true
	btnArmory.disabled = true
	
	btnArena.text = "Closed (Night)"
	btnShop.text = "Closed"
	btnArmory.text = "Closed"
	
	# Textfarbe auf Weiß setzen
	if goldLabel:
		goldLabel.add_theme_color_override("font_color", Color.WHITE)
	if dayLabel:
		dayLabel.add_theme_color_override("font_color", Color.WHITE)

	
# Diese Funktionen erstellen wir gleich über Signale
func _on_btn_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
	
	
func _on_btn_armory_pressed():
	#TODO Logik, Tag hochzählen etc.
	get_tree().change_scene_to_file("res://scenes/armory.tscn")
	
	
func _on_btn_arena_pressed():
	#TODO Logik, Tag hochzählen etc.
	get_tree().change_scene_to_file("res://scenes/arena_prep.tscn")
