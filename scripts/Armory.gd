extends Control

# UI Referenzen (camelCase)
@onready var goldLabel = %GoldLabel
@onready var gridContainer = $MarginContainer/VBoxContainer/GridContainer 

# Vorlage laden (camelCase)
var shopItemScene = preload("res://scenes/shop_item.tscn")

# Daten-Liste (camelCase)
var shopInventory = [
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
	{"name": "Plate Armor", "type": "Armor", "bonus": 5, "price": 100, "icon": "res://assets/sprites/plate.png"}
]

func _ready():
	update_ui()
	generate_shop_items()
	
func update_ui():
	# Nutzt camelCase Variable 'currentGold' im GameManager
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	# Alle items im Shop aktualisieren
	var allItems = gridContainer.get_children()
	
	for item in allItems:
		if item.has_method("check_affordability"):
			item.check_affordability()
	
func generate_shop_items():
	for itemData in shopInventory:
		var newItem = shopItemScene.instantiate()
		
		# HIER WAR DER FEHLER: gridContainer (klein geschrieben!)
		gridContainer.add_child(newItem)
		
		newItem.set_item_data(itemData)
		
func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
	
func _process(delta):
	if goldLabel.text != "Gold: " + str(GameManager.currentGold):
		update_ui()
