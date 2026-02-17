extends Control

# --- UI REFERENZEN ---
@onready var background = %Background

# Buttons (Frei platziert)
@onready var btnBack = %BtnBack
@onready var btnFood = %BtnFood
@onready var btnEvents = %BtnEvents
@onready var btnRumors = %BtnRumors
@onready var btnSleep = %BtnSleep

# --- ASSETS ---
# Achtung: Pfade prüfen (jpg vs png), aber wenn es vorher ging, passt das.
var img_day = preload("res://assets/sprites/tavern-day-bg.jpg")
var img_night = preload("res://assets/sprites/tavern-night-bg.jpg")

func _ready():
	# WICHTIG: Achte darauf, dass das Signal korrekt verbunden ist
	# (manchmal doppelt man das, wenn man es auch im Editor verbunden hat)
	if not btnSleep.pressed.is_connected(_on_btn_sleep_pressed):
		btnSleep.pressed.connect(_on_btn_sleep_pressed)
	
	# Start-Check: Wir rufen direkt die neue Funktion auf
	update_ui()

# WICHTIG: Diese Funktion hieß vorher "update_visuals".
# Wir haben sie in "update_ui" umbenannt, damit main.gd sie findet!
func update_ui():
	print("Taverne: Update UI wird ausgeführt...") # Debug Nachricht
	if GameManager.is_night:
		setup_night_mode()
	else:
		setup_day_mode()

func setup_night_mode():
	background.texture = img_night
	
	# Nachts: Schlafen & Gerüchte sichtbar
	btnRumors.visible = true
	btnSleep.visible = true
	
func setup_day_mode():
	background.texture = img_day
	
	# Tagsüber: Schlafen & Gerüchte weg
	btnRumors.visible = false
	btnSleep.visible = false
	

# --- ACTIONS ---

func _on_btn_sleep_pressed():
	# 1. Gold prüfen und abziehen
	if GameManager.currentGold >= 10:
		GameManager.currentGold -= 10
		
		# WICHTIG: Hier NUR den Effekt starten. 
		# Keine Variablen wie "is_night" ändern! Das macht das Main-Script für uns.
		if GameManager.main_node:
			GameManager.main_node.play_sleep_effect()
			
	else:
		print("Nicht genug Gold!")
