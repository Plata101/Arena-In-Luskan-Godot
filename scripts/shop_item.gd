extends PanelContainer

# UI Referenzen
@onready var iconRect = %TextureRect 
@onready var nameLabel = %Label 
@onready var buyButton = %BtnBuy 

# Interne Variablen
var itemPrice: int = 0
var statBonus: int = 0
var statType: String = "" 

func set_item_data(data):
	itemPrice = data["price"]
	statBonus = data["bonus"]
	statType = data["type"] 
	
	nameLabel.text = data["name"] + "\n(+" + str(statBonus) + " " + statType + ")\n" + str(itemPrice) + " Gold"
	
	buyButton.text = "Kaufen (" + str(itemPrice) + " G)"
	
	if data.has("icon"):
		iconRect.texture = load(data["icon"]) 
	
	check_affordability()
	
func check_affordability():
	if GameManager.currentGold < itemPrice:
		buyButton.disabled = true
	else:
		buyButton.disabled = false
		
func _on_btn_buy_pressed():
	if GameManager.currentGold >= itemPrice:
		# Bezahlen
		GameManager.currentGold -= itemPrice
		
		# Stats anpassen
		if statType == "Strength":
			GameManager.playerStrength += statBonus
			print("Strength increased")
		elif statType == "Armor":
			# Sicherstellen, dass playerArmor im GameManager existiert
			GameManager.playerArmor += statBonus
			print("Armor increased")

		# UI updaten
		check_affordability()
