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

# --- UNSER TEXT-PAKET FÜR THORFIN ---
var thorfin_dialogue = {
	"start": {
		"text": "Well met, stranger. What brings you to this gloomy place?",
		"choices": [
			{"text": "Well met too, what news on the riddermark?", "next_node": "news"},
			{"text": "Howdy, I see you already had 5 glasses of beer.", "next_node": "drunk"},
			{"text": "Just passing through. (Leave)", "next_node": "end"}
		]
	},
	"news": {
		"text": "The orks are gathering in the mountains. Dark times are ahead of us.",
		"choices": [
			{"text": "I will slay them all! (Good Alignment)", "next_node": "end"},
			{"text": "Not my problem. (Leave)", "next_node": "end"}
		]
	},
	"drunk": {
		"text": "Mind your own business, you scoundrel! *hiccup*",
		"choices": [
			{"text": "Sorry, my bad. (Leave)", "next_node": "end"}
		]
	}
}

# --- NEU: DIALOG 2: BARKEEPER ---
var bartender_dialogue = {
	"start": {
		"text": "Welcome to the Dragon's Tankard! Best ale in all of Luskan. What can I get ya?",
		"choices": [
			{"text": "A pint of your finest ale, please.", "next_node": "ale"},
			{"text": "Just looking around. (Leave)", "next_node": "end"}
		]
	},
	"ale": {
		"text": "Here you go! Drink up, it puts hair on your chest.",
		"choices": [
			{"text": "Thanks! (Leave)", "next_node": "end"}
		]
	}
}


func _ready():
	# WICHTIG: Achte darauf, dass das Signal korrekt verbunden ist
	# (manchmal doppelt man das, wenn man es auch im Editor verbunden hat)
	if not btnSleep.pressed.is_connected(_on_btn_sleep_pressed):
		btnSleep.pressed.connect(_on_btn_sleep_pressed)
		
	if btnRumors:
		btnRumors.pressed.connect(_on_rumors_pressed)
		
	if btnBartender:
		btnBartender.pressed.connect(_on_bartender_pressed)
	
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
		thorfin_dialogue
	)
	
func _on_bartender_pressed():
	var dialogue_instance = dialogue_scene.instantiate()
	add_child(dialogue_instance) # Gleiches Overlay laden!
	
	# Aber diesmal übergeben wir dem Overlay GANZ ANDERE DATEN:
	dialogue_instance.setup_dialogue(
		"Tomas M. Agnum", # Anderer Name
		"Innkeeper", # Anderer Beruf
		"res://assets/sprites/npcs/npc_tomas_inkeeper.png", # WICHTIG: Pfad zu deinem Barkeeper-Bild anpassen!
		bartender_dialogue # Anderes Text-Paket
	)
	


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
