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
		# --- SHOP MODUS (GROSS) ---
		# Hier müssen wir sicherstellen, dass alles sichtbar ist (falls recycled)
		iconRect.visible = true
		nameLabel.visible = true
		
		var bonusText = "(+" + str(data["bonus"]) + " " + data["type"] + ")"
		nameLabel.text = data["name"] + "\n" + bonusText + "\n" + str(data["price"]) + " Gold"
		
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
		# 1. Bezahlen
		GameManager.currentGold -= itemData["price"]
		
		# 3. WICHTIG: Item ins globale Inventar legen!
		GameManager.inventory.append(itemData)
		# 4. Update Gold Label
		if GameManager.main_node:
			GameManager.main_node.update_ui()
		
		print("Purchased: ", itemData["name"])
		
		# UI Check triggern (via Armory update)
		# Da wir keine Signale nutzen, warten wir auf den _process loop der Armory

# --- LOGIK FÜR VERKAUFEN ---
func sell_item():
	# 1. Geld zurück (60%)
	var sellPrice = int(itemData["price"] * 0.6)
	GameManager.currentGold += sellPrice
	
	
	# 3. Aus globalem Inventar löschen
	# erase entfernt das erste Vorkommen dieses Daten-Objekts
	GameManager.inventory.erase(itemData)
	
	# 4. Update Gold Label
	if GameManager.main_node:
		GameManager.main_node.update_ui()
	
	print("Sold: ", itemData["name"])
	
	# 4. Item aus der UI entfernen (Selbstzerstörung)
	queue_free()
