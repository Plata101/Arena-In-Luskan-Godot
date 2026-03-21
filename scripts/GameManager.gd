extends Node

# Referenz zur Main-Szene
var main_node = null

# Spieler-Daten

# --- NEUE SPIELER-DATEN ---
var playerImage: String
var player_name: String = "Unknown"
var player_class: String = ""

var currentGold: int
var playerHp: int
var playerMaxHp: int
var playerStrength: int
var playerArmor: int = 0

# Neue Stats
var playerStamina: int
var playerDexterity: int
var playerLuck: int

var playerEndurance: int
var playerMaxEndurance: int
var playerActionPoints: int = 2
var playerArmorClass: int = 10 # Basis-Rüstung

var playerAlignment: String = ""

# Equipment Slots (Hier speichern wir die ausgerüsteten Dictionaries)
var equipped_weapon = null
var equipped_armor = null
var equipped_trinket = null

# Spiel-Status
var currentDay: int = 1
var maxDays: int = 100
var beers_drank_today: int = 0

# --- QUEST SYSTEM ---
var active_quests: Array[Dictionary] = []


# Sammelt alle Events des aktuellen Tages
var daily_events: Array[Dictionary] = []

# --- SHOP SYSTEM ---
var current_shop_type: String = "Armory" # Merkt sich, wo wir sind
# Inventory

# 1. Das echte Inventar des Schmieds
var armory_inventory: Array[Dictionary] = [
	# --- WAFFEN ---
	{"name": "Dagger", "type": "Strength", "bonus": 1, "price": 5, "icon": "res://assets/sprites/items/dagger.png"},
	{"name": "Shortsword", "type": "Strength", "bonus": 2, "price": 10, "icon": "res://assets/sprites/items/sword.png"},
	{"name": "Axe", "type": "Strength", "bonus": 2, "price": 8, "icon": "res://assets/sprites/items/axe.png"},
	{"name": "Pike", "type": "Strength", "bonus": 3, "price": 20, "icon": "res://assets/sprites/items/pike.png"},
	{"name": "Morningstar", "type": "Strength", "bonus": 3, "price": 25, "icon": "res://assets/sprites/items/morningstar.png"},
	
	# --- ARMOR ---
	{"name": "Cloth Doublet", "type": "Armor", "bonus": 1, "price": 15, "icon": "res://assets/sprites/items/studded.png"},
	{"name": "Leather Armor", "type": "Armor", "bonus": 2, "price": 25, "icon": "res://assets/sprites/items/leather.png"},
	{"name": "Chainmail", "type": "Armor", "bonus": 3, "price": 35, "icon": "res://assets/sprites/items/chain.png"},
	{"name": "Scale Mail", "type": "Armor", "bonus": 4, "price": 50, "icon": "res://assets/sprites/items/scale.png"},
	{"name": "Plate Armor", "type": "Armor", "bonus": 5, "price": 100, "icon": "res://assets/sprites/items/plate.png"},
	{"name": "Plate Armor2", "type": "Armor", "bonus": 5, "price": 100, "icon": "res://assets/sprites/items/plate.png"}
]

# 2. Das echte Inventar des Alchemisten / Gemischtwarenhändlers
var potions_inventory: Array[Dictionary] = [
	{"name": "Healing Potion", "type": "Potion", "bonus": 20, "price": 100, "icon": "res://assets/sprites/items/potion_blue.png"},
	{"name": "Mysterious Ring", "type": "Trinket", "bonus": 2, "price": 100, "icon": "res://assets/sprites/items/ring_ruby.png"},
]

# 3. Der "Zeiger" für die Shop-Szene (bleibt am Anfang leer!)
var shop_inventory: Array[Dictionary] = []

# Player Inventory
var inventory: Array = [
	{"name": "Healing Potion", "type": "Potion", "bonus": 20, "price": 100, "icon": "res://assets/sprites/items/potion_blue.png"},
	{"name": "Mysterious Ring", "type": "Trinket", "bonus": 2, "price": 100, "icon": "res://assets/sprites/items/ring_ruby.png"},
	{"name": "Letter", "type": "Misc", "bonus": 0, "price": 0, "icon": "res://assets/sprites/items/scroll.png"},
]



var currentEnemy = {} # Hier speichern wir das ausgewählte Monster vor dem Szenenwechsel

# NEUE VARIABLEN FÜR DEN LOOP
var current_day = 1
var is_night = false


func _ready():
	# Sortiert den Shop direkt beim Start einmal durch
	sort_inventories()
	
	
func setup_player(chosen_class: String):
	player_class = chosen_class
	
	if chosen_class == "Warrior":
		playerImage = "res://assets/sprites/warrior.jpg"
		active_quests.append({"title": "- MQ: ", "desc": "Get a date with the princess"})
		active_quests.append({"title": "", "desc": "- Win your first fight in the arena"})
		active_quests.append({"title": "", "desc": "- Drink twenty beers in tavern"})
		currentGold = 100
		playerMaxHp = 100
		playerMaxEndurance = 150
		playerStrength = 6
		playerStamina = 6
		playerDexterity = 4
		playerLuck = 2
		playerAlignment = "Neutral"
		inventory.append({"name": "Guard Armor", "type": "Armor", "bonus": 2, "price": 15, "icon": "res://assets/sprites/items/leather.png"})
		inventory.append({"name": "Rusty Sword", "type": "Armor", "bonus": 2, "price": 15, "icon": "res://assets/sprites/items/sword.png"})
		# Hier später Start-Items (Schwert & Rüstung) ins Inventar pushen
		
	elif chosen_class == "Thief":
		playerImage = "res://assets/sprites/thief.jpg"
		active_quests.append({"title": "- Main: ", "desc": "Loot the kings treasure chamber"})
		active_quests.append({"title": "", "desc": "- Win your first fight in the arena"})
		active_quests.append({"title": "", "desc": "- Drink twenty beers in tavern"})
		active_quests.append({"title": "", "desc": "- Drink foury beers in tavern"})
		currentGold = 200
		playerMaxHp = 80
		playerMaxEndurance = 120
		playerStrength = 3
		playerStamina = 4
		playerDexterity = 6
		playerLuck = 6
		playerAlignment = "Evil"
		inventory.append({"name": "Blood-Dagger", "type": "Strength", "bonus": 3, "price": 30, "icon": "res://assets/sprites/items/dagger.png"})
		
	elif chosen_class == "Brawler":
		playerImage = "res://assets/sprites/brawler.jpg"
		active_quests.append({"title": "- MQ: ", "desc": "Become the Grand Champion to restore your family's honor"})
		active_quests.append({"title": "", "desc": "- Win your first fight in the arena"})
		active_quests.append({"title": "", "desc": "- Drink twenty beers in tavern"})
		currentGold = 50
		playerMaxHp = 150
		playerMaxEndurance = 200
		playerStrength = 7
		playerStamina = 7
		playerDexterity = 3
		playerLuck = 4
		playerAlignment = "Good"
		inventory.append({"name": "Scale Mail", "type": "Armor", "bonus": 4, "price": 50, "icon": "res://assets/sprites/items/scale.png"})
		inventory.append({"name": "Broadsword", "type": "Strength", "bonus": 5, "price": 10, "icon": "res://assets/sprites/items/sword.png"})
	# Am Ende HP voll machen!
	playerHp = playerMaxHp
	playerEndurance = playerMaxEndurance

func sort_inventories():
	# Sortiert alle Arrays alphabetisch (A-Z) basierend auf dem "name"-Wert
	armory_inventory.sort_custom(func(a, b): return a["name"] < b["name"])
	potions_inventory.sort_custom(func(a, b): return a["name"] < b["name"])
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
