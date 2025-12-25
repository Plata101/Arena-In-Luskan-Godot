extends Control

# UI Referenzen
@onready var goldLabel = %GoldLabel
@onready var gridContainer = %GridContainer
@onready var inventoryGrid = %InventoryGrid

# Vorlage laden
var shopItemScene = preload("res://scenes/shop_item.tscn")

# Variable um zu merken, wie voll das Inventar ist (für Updates)
var currentInventorySize = 0

# Daten-Liste
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
	update_inventory_view() # NEU: Initiales Laden des Inventars
	
func update_ui():
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	# Alle items im Shop aktualisieren (Buttons disablen wenn zu teuer)
	var allItems = gridContainer.get_children()
	
	for item in allItems:
		if item.has_method("check_affordability"):
			item.check_affordability()
	
func generate_shop_items():
	for itemData in shopInventory:
		var newItem = shopItemScene.instantiate()
		gridContainer.add_child(newItem)
		
		# WICHTIG: false übergeben für Shop-Modus (Kaufen)
		newItem.set_item_data(itemData, false) 

# NEU: Diese Funktion kümmert sich um die rechte Seite (Inventar)
func update_inventory_view():
	# 1. Altes Inventar UI löschen (aufräumen)
	for child in inventoryGrid.get_children():
		child.queue_free()
	
	# 2. Neues Inventar basierend auf GameManager aufbauen
	for itemData in GameManager.inventory:
		var newItem = shopItemScene.instantiate()
		inventoryGrid.add_child(newItem)
		
		# WICHTIG: true übergeben für Inventar-Modus (Verkaufen)
		newItem.set_item_data(itemData, true) 
	
	# Größe merken, damit wir im _process wissen, wann sich was geändert hat
	currentInventorySize = GameManager.inventory.size()
		
func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
	
func _process(delta):
	# Update Gold Anzeige
	if goldLabel.text != "Gold: " + str(GameManager.currentGold):
		update_ui()
	
	# NEU: Update Inventory Anzeige (wenn Items gekauft/verkauft wurden)
	if GameManager.inventory.size() != currentInventorySize:
		update_inventory_view()
