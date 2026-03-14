extends Control

# --- UI REFERENZEN ---
@onready var background = %Background

# Buttons (Frei platziert)
@onready var btnBack = %BtnBack
@onready var btnBartender = %BtnBartender
@onready var btnEvents = %BtnEvents
@onready var btnRumors = %BtnRumors
@onready var btnSleep = %BtnSleep

# --- ASSETS ---
# Achtung: Pfade prüfen (jpg vs png), aber wenn es vorher ging, passt das.
var img_day = preload("res://assets/sprites/tavern-day-bg.jpg")
var img_night = preload("res://assets/sprites/tavern-night-bg.jpg")
var dialogue_scene = preload("res://scenes/dialogue_overlay.tscn")
var event_modal_scene = preload("res://scenes/event_modal.tscn")

func _ready():
	# WICHTIG: Achte darauf, dass das Signal korrekt verbunden ist
	# (manchmal doppelt man das, wenn man es auch im Editor verbunden hat)
	if not btnSleep.pressed.is_connected(_on_btn_sleep_pressed):
		btnSleep.pressed.connect(_on_btn_sleep_pressed)
		
	if btnRumors:
		btnRumors.pressed.connect(_on_rumors_pressed)
		
	if btnBartender:
		btnBartender.pressed.connect(_on_bartender_pressed)
	
	if btnEvents:
		btnEvents.pressed.connect(_on_btn_events_pressed)
	
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

func _on_rumors_pressed():
	# Erschaffe eine Kopie (Instanz) des Dialog-Overlays
	var dialogue_instance = dialogue_scene.instantiate()
	
		# Danach fügen wir es der Szene hinzu (der Fade-In startet automatisch!)
	add_child(dialogue_instance)
# --- HIER PASSIERT DIE MAGIE ---
	# Wir rufen setup_dialogue auf und geben ihm alle Infos:
	# Name, Beruf, Pfad zum Bild, und das Dictionary mit dem Text
	dialogue_instance.setup_dialogue(
		"Thorfin", 
		"Sailor", 
		"res://assets/sprites/npcs/thorfin.png", # WICHTIG: Ersetze das mit deinem echten Pfad zum Thorfin-Bild!
		Dialogues.thorfin
	)
	
func _on_bartender_pressed():
	var dialogue_instance = dialogue_scene.instantiate()
	add_child(dialogue_instance) # Gleiches Overlay laden!
	
	# Aber diesmal übergeben wir dem Overlay GANZ ANDERE DATEN:
	dialogue_instance.setup_dialogue(
		"Tomas M. Agnum", # Anderer Name
		"Innkeeper", # Anderer Beruf
		"res://assets/sprites/npcs/npc_tomas_inkeeper.png", # WICHTIG: Pfad zu deinem Barkeeper-Bild anpassen!
		Dialogues.inkeeper # Anderes Text-Paket
	)
	


func _on_btn_sleep_pressed():
	if GameManager.daily_events.size() > 0:
		# Modal öffnen und zwingen, sie zu lesen!
		openModal()
	else:
		# 1. Gold prüfen und abziehen
		if GameManager.currentGold >= 10:
			GameManager.currentGold -= 10
			
		GameManager.beers_drank_today = 0
			
		# WICHTIG: Hier NUR den Effekt starten. 
		# Keine Variablen wie "is_night" ändern! Das macht das Main-Script für uns.
		if GameManager.main_node:
			GameManager.main_node.play_sleep_effect()
				
		else:
			print("Nicht genug Gold!")

func _on_btn_events_pressed():
	print("Show event")
	openModal()


func openModal():
	var modal = event_modal_scene.instantiate()
	add_child(modal)
	
	# Prüfen, ob wir echte Events haben
	if GameManager.daily_events.size() > 0:
		modal.setup(GameManager.daily_events)
	else:
		# Dummy-Liste erstellen, wenn keine Events da sind
		var empty_event_list: Array[Dictionary] = [
			{ "text": "No events have happened." }
		]
		modal.setup(empty_event_list)
	
