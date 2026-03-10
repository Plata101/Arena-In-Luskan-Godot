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
var equipped_trinket = null

# Spiel-Status
var currentDay: int = 1
var maxDays: int = 100
var beers_drank_today: int = 0

# Inventory

var shop_inventory: Array = [
	# --- WAFFEN ---
	{"name": "Dagger", "type": "Strength", "bonus": 1, "price": 5, "icon": "res://assets/sprites/dagger.png"},
	{"name": "Shortsword", "type": "Strength", "bonus": 2, "price": 10, "icon": "res://assets/sprites/sword.png"},
	{"name": "Axe", "type": "Strength", "bonus": 2, "price": 8, "icon": "res://assets/sprites/axe.png"},
	{"name": "Pike", "type": "Strength", "bonus": 3, "price": 20, "icon": "res://assets/sprites/pike.png"},
	{"name": "Morningstar", "type": "Strength", "bonus": 3, "price": 25, "icon": "res://assets/sprites/morningstar.png"},
	
	# --- ARMOR ---
	{"name": "Cloth Doublet", "type": "Armor", "bonus": 1, "price": 15, "icon": "res://assets/sprites/studded.png"},
	{"name": "Leather Armor", "type": "Armor", "bonus": 2, "price": 25, "icon": "res://assets/sprites/leather.png"},
	{"name": "Chainmail", "type": "Armor", "bonus": 3, "price": 35, "icon": "res://assets/sprites/chain.png"},
	{"name": "Scale Mail", "type": "Armor", "bonus": 4, "price": 50, "icon": "res://assets/sprites/scale.png"},
	{"name": "Plate Armor", "type": "Armor", "bonus": 5, "price": 100, "icon": "res://assets/sprites/plate.png"},
	{"name": "Plate Armor2", "type": "Armor", "bonus": 5, "price": 100, "icon": "res://assets/sprites/plate.png"}
]

# Player Inventory
var inventory: Array = [
	{"name": "Healing Potion", "type": "Potion", "bonus": 20, "price": 100, "icon": "res://assets/sprites/potion_blue.png"},
	{"name": "Mysterious Ring", "type": "Trinket", "bonus": 2, "price": 100, "icon": "res://assets/sprites/ring_ruby.png"},
	{"name": "Letter", "type": "Misc", "bonus": 0, "price": 0, "icon": "res://assets/sprites/scroll.png"},
]

var currentEnemy = {} # Hier speichern wir das ausgewählte Monster vor dem Szenenwechsel

# NEUE VARIABLEN FÜR DEN LOOP
var current_day = 1
var is_night = false


func _ready():
	# Sortiert den Shop direkt beim Start einmal durch
	sort_inventories()

func sort_inventories():
	# Sortiert beide Arrays alphabetisch (A-Z) basierend auf dem "name"-Wert
	shop_inventory.sort_custom(func(a, b): return a["name"] < b["name"])
	inventory.sort_custom(func(a, b): return a["name"] < b["name"])


# Neue Funktion für Szenenwechsel
func change_scene(new_scene_path: String):
	if main_node:
		# Ruft die neue Funktion im main.gd auf
		main_node.change_scene(new_scene_path)
		main_node.update_ui() # UI (Gold/Tag) aktualisieren
	else:
		# Fallback, falls man Main nicht gestartet hat (z.B. beim Testen)
		get_tree().change_scene_to_file(new_scene_path)
