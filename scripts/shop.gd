extends Control

@onready var gridContainer = %GridContainer
@onready var inventoryGrid = %InventoryGrid
@onready var blackOverlay = %BlackOverlay
@onready var background = %Background
@onready var inventoryIcon = %InventoryIcon

var shopItemScene = preload("res://scenes/shop_item.tscn")

var currentInventorySize = 0
var currentShopSize = 0 # NEU: Größe des Shops merken

func _ready():
	setup_shop_visuals()
	update_shop_view() # <--- Geändert
	update_inventory_view() 

func setup_shop_visuals():
	# Wenn du einen Background Node hast (z.B. @onready var background = %Background),
	# kannst du hier das Bild tauschen!
	if GameManager.current_shop_type == "Armory":
		background.texture = preload("res://assets/sprites/armory_bg.jpg")
		inventoryIcon.texture = preload("res://assets/sprites/inventory-icons/icon_weapon_armor.png")
	elif GameManager.current_shop_type == "Potions":
		background.texture = preload("res://assets/sprites/potions_sundries_bg.jpg")
		inventoryIcon.texture = preload("res://assets/sprites/inventory-icons/icon_potions.png")
	
func update_ui():
	var allItems = gridContainer.get_children()
	for item in allItems:
		if item.has_method("check_affordability"):
			item.check_affordability()

# NEUE FUNKTION: Baut den Shop komplett auf
func update_shop_view():
	# 1. Alte Shop-UI löschen
	for child in gridContainer.get_children():
		child.queue_free()
		
	# 2. Aus GameManager neu laden
	for itemData in GameManager.shop_inventory:
		var newItem = shopItemScene.instantiate()
		gridContainer.add_child(newItem)
		newItem.set_item_data(itemData, false) 
		
	currentShopSize = GameManager.shop_inventory.size()
	update_ui() # Checkt, ob wir genug Geld haben

func update_inventory_view():
	for child in inventoryGrid.get_children():
		child.queue_free()
	
	for itemData in GameManager.inventory:
		var type = itemData.get("type", "")
		var should_show = false
		
		# --- DER UNIVERSELLE FILTER ---
		if GameManager.current_shop_type == "Armory":
			if type == "Strength" or type == "Armor":
				should_show = true
				
		elif GameManager.current_shop_type == "Potions":
			if type == "Potion" or type == "Trinket" or type == "Misc":
				should_show = true
				
		# Wenn das Item zum Shop passt, zeigen wir es an!
		if should_show:
			var newItem = shopItemScene.instantiate()
			inventoryGrid.add_child(newItem)
			newItem.set_item_data(itemData, true) 
	
	currentInventorySize = GameManager.inventory.size()
			
func _process(delta):
	# Update Inventar (wenn Items gekauft/verkauft wurden)
	if GameManager.inventory.size() != currentInventorySize:
		update_inventory_view()
		
	# NEU: Update Shop (wenn Items aus dem Shop verschwinden/auftauchen)
	if GameManager.shop_inventory.size() != currentShopSize:
		update_shop_view()
