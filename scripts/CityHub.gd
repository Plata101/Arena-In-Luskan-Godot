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
	# FADE IN (Vorhang auf)
	# Wir zwingen es sicherheitshalber auf Schwarz (falls im Editor vergessen)
	blackOverlay.modulate.a = 1.0 
	
	var tween = create_tween()
	# In 1.0 Sekunden von Schwarz (1) zu Transparent (0)
	tween.tween_property(blackOverlay, "modulate:a", 0.0, 0.4)
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
	# --- FADE IN EFFEKT (Vorhang auf!) ---
	# Wir starten schwarz (im Editor eingestellt) und werden transparent
	var tween = create_tween()
	tween.tween_property(blackOverlay, "modulate:a", 0.0, 0.4) # 1 Sekunde Dauer
	
	
func setup_day():
	background.texture = img_day
	
	# Alles geöffnet
	btnArena.visible = true
	btnShop.visible = true
	btnArmory.visible = true
	
	if goldLabel:
		goldLabel.add_theme_color_override("font_color", Color.BLACK) 
	if dayLabel:
		dayLabel.add_theme_color_override("font_color", Color.BLACK)

func setup_night():
	background.texture = img_night
	
	# Bei Nacht hat alles zu (außer die Taverne!)
	btnArena.visible = false
	btnShop.visible = false
	btnArmory.visible = false
	
	
	# Textfarbe auf Weiß setzen
	if goldLabel:
		goldLabel.add_theme_color_override("font_color", Color.WHITE)
	if dayLabel:
		dayLabel.add_theme_color_override("font_color", Color.WHITE)

# --- SZENENWECHSEL HELFER ---

func transition_to_scene(scene_path):
	# 1. Maus blockieren (damit man nicht wild rumklickt während des Fades)
	blackOverlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fade Out (zu Schwarz)
	var tween = create_tween()
	tween.tween_property(blackOverlay, "modulate:a", 1.0, 0.4) # 0.5 Sek geht schneller
	
	# 3. Warten und Szene wechseln
	await tween.finished
	get_tree().change_scene_to_file(scene_path)


	
# Diese Funktionen erstellen wir gleich über Signale
func _on_btn_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
	
	
func _on_btn_armory_pressed():
	#TODO Logik, Tag hochzählen etc.
	transition_to_scene("res://scenes/armory.tscn")
	
	
func _on_btn_arena_pressed():
	#TODO Logik, Tag hochzählen etc.
	transition_to_scene("res://scenes/arena_prep.tscn")


func _on_btn_tavern_pressed():
	transition_to_scene("res://scenes/tavern.tscn")
