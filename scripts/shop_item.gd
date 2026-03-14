extends PanelContainer

# UI Referenzen
@onready var iconRect = %TextureRect 
@onready var nameLabel = %Label 
@onready var buyButton = %BtnBuy 

# Interne Variablen
var itemData = {}             # NEU: Wir merken uns das ganze Objekt
var isInventoryItem = false   # NEU: Modus-Schalter

func set_item_data(data, isInventory: bool = false):
	itemData = data
	isInventoryItem = isInventory
	
	# Icon immer laden (für den Shop), aber...
	if data.has("icon"):
		iconRect.texture = load(data["icon"]) 
	
	# --- UNTERSCHEIDUNG: SHOP VS. INVENTAR ---
	if isInventoryItem:
		# --- INVENTAR MODUS (KOMPAKT) ---
		var sellPrice = int(data["price"] * 0.6)
		
		# 1. Bild und großes Label verstecken
		iconRect.visible = false
		nameLabel.visible = false 
		
		# 2. Alles auf den Button schreiben
		# Format: "Pike - Sell (12 G)"
		buyButton.text = data["name"] + " - Sell (" + str(sellPrice) + " G)"
		
		# Visueller Hinweis: Rötlich
		buyButton.modulate = Color(1, 0.6, 0.6)
		buyButton.disabled = false 
		
	else:
		iconRect.visible = true
		nameLabel.visible = true
		
		# SICHERHEITS-CHECK: Hat das Item überhaupt einen Bonus?
		var bonusText = ""
		if data.has("bonus") and data.has("type"):
			if data["type"] == "Potion":
				bonusText = "(Heals " + str(data["bonus"]) + " HP)" # Text für Tränke
			else:
				bonusText = "(+" + str(data["bonus"]) + " " + data["type"] + ")" # Text für Waffen/Rüstung
		
		# Label zusammensetzen (mit oder ohne Bonus)
		if bonusText != "":
			nameLabel.text = data["name"] + "\n" + bonusText + "\n" + str(data["price"]) + " Gold"
		else:
			nameLabel.text = data["name"] + "\n\n" + str(data["price"]) + " Gold"
		
		buyButton.text = "Buy (" + str(data["price"]) + " G)"
		buyButton.modulate = Color(1, 1, 1) # Normal weiß
		check_affordability()

func check_affordability():
	# Geld-Check macht nur Sinn, wenn wir kaufen wollen
	if not isInventoryItem:
		if GameManager.currentGold < itemData["price"]:
			buyButton.disabled = true
		else:
			buyButton.disabled = false

func _on_btn_buy_pressed():
	if isInventoryItem:
		sell_item()
	else:
		buy_item()

# --- LOGIK FÜR KAUFEN ---
func buy_item():
	if GameManager.currentGold >= itemData["price"]:
		GameManager.currentGold -= itemData["price"]
		
		# 1. Aus dem Shop löschen
		GameManager.shop_inventory.erase(itemData)
		
		# 2. Ins Spieler-Inventar legen
		GameManager.inventory.append(itemData)
		
		# --- NEU: Listen direkt neu sortieren ---
		GameManager.sort_inventories()
		
		if GameManager.main_node:
			GameManager.main_node.update_ui()
		print("Purchased: ", itemData["name"])

func sell_item():
	var sellPrice = int(itemData["price"] * 0.6)
	GameManager.currentGold += sellPrice
	
	if GameManager.equipped_weapon == itemData:
		GameManager.equipped_weapon = null
	elif GameManager.equipped_armor == itemData:
		GameManager.equipped_armor = null
	
	# 1. Aus dem Spieler-Inventar löschen
	GameManager.inventory.erase(itemData)
	
	# 2. Zurück in den Shop legen
	GameManager.shop_inventory.append(itemData)
	
	# --- NEU: Listen direkt neu sortieren ---
	GameManager.sort_inventories()
	
	if GameManager.main_node:
		GameManager.main_node.update_ui()
	print("Sold: ", itemData["name"])
	queue_free()
