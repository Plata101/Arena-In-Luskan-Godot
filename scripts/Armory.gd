extends Control

@onready var gridContainer = %GridContainer
@onready var inventoryGrid = %InventoryGrid
@onready var blackOverlay = %BlackOverlay

var shopItemScene = preload("res://scenes/shop_item.tscn")

var currentInventorySize = 0
var currentShopSize = 0 # NEU: Größe des Shops merken

func _ready():
	update_shop_view() # <--- Geändert
	update_inventory_view() 
	
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
		# --- NEU: Der Filter! ---
		var type = itemData.get("type", "")
		# Wir zeigen das Item NUR an, wenn es Waffe oder Rüstung ist
		if type == "Strength" or type == "Armor":
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
