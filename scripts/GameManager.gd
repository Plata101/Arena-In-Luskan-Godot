extends Node

# Referenz zur Main-Szene
var main_node = null

# Neue Funktion für Szenenwechsel
func change_scene(new_scene_path: String):
	if main_node:
		# Ruft die neue Funktion im main.gd auf
		main_node.change_scene(new_scene_path)
		main_node.update_ui() # UI (Gold/Tag) aktualisieren
	else:
		# Fallback, falls man Main nicht gestartet hat (z.B. beim Testen)
		get_tree().change_scene_to_file(new_scene_path)


# Spieler-Daten
var currentGold: int = 100
var playerHp: int = 100
var playerMaxHp: int = 100
var playerStrength: int = 5
var playerArmor: int = 0

# Spiel-Status
var currentDay: int = 1
var maxDays: int = 100

# Inventory

var inventory: Array = []

var currentEnemy = {} # Hier speichern wir das ausgewählte Monster vor dem Szenenwechsel

# NEUE VARIABLEN FÜR DEN LOOP
var current_day = 1
var is_night = false
