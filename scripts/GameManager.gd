extends Node

# Referenz zur Main-Szene
var main_node = null

# Spieler-Daten
var currentGold: int = 100
var playerHp: int = 100
var playerMaxHp: int = 100
var playerStrength: int = 5
var playerArmor: int = 0

# Neue Stats
var playerStamina: int = 5
var playerDexterity: int = 5
var playerLuck: int = 5

var playerEndurance: int = 100
var playerMaxEndurance: int = 100
var playerActionPoints: int = 2
var playerArmorClass: int = 10 # Basis-Rüstung

# Equipment Slots (Hier speichern wir die ausgerüsteten Dictionaries)
var equipped_weapon = null
var equipped_armor = null

# Spiel-Status
var currentDay: int = 1
var maxDays: int = 100

# Inventory

var inventory: Array = []

var currentEnemy = {} # Hier speichern wir das ausgewählte Monster vor dem Szenenwechsel

# NEUE VARIABLEN FÜR DEN LOOP
var current_day = 1
var is_night = false

# Neue Funktion für Szenenwechsel
func change_scene(new_scene_path: String):
	if main_node:
		# Ruft die neue Funktion im main.gd auf
		main_node.change_scene(new_scene_path)
		main_node.update_ui() # UI (Gold/Tag) aktualisieren
	else:
		# Fallback, falls man Main nicht gestartet hat (z.B. beim Testen)
		get_tree().change_scene_to_file(new_scene_path)
