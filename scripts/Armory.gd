extends Control
# Wir holen uns die UI-Element über ihre Unique Names (%)
@onready var goldLabel = %GoldLabel
@onready var buyButton = %BtnBuySword

# Die Daten für unser Schwert
var swordPrice = 10
var strengthBonus = 1

func _ready():
	# Wenn die Szene startet, aktualisieren wir sofor die Anzeige 
	update_ui()
	
func update_ui():
	# 1. Gold-Anzeige aktualisieren
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	# 2. Prüfen: Haben wir genug Gold?
	if GameManager.currentGold < swordPrice:
		# Wenn nein: Button deaktivieren und Text ändern
		buyButton.disabled = true
		buyButton.text = "Too expensive (" + str(swordPrice) + " G)"
	else:
		# Wenn ja: Button aktivieren
		buyButton.disabled = false
		buyButton.text = "Buy (" + str(swordPrice) + " G)"

# --- Diese Funktionen verbinden wir gleich! ---

func _on_btn_back_pressed():
	# Zurück zum Hub
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
	
func _on_btn_buy_sword_pressed():
	# Sicherheitshalber nochmal prüfen
	if GameManager.currentGold >= swordPrice:
		# 1. Bezahlen
		GameManager.currentGold -= swordPrice
		# 2. Ware erhalen (Stärke erhöhen)
		GameManager.playerStrength += strengthBonus
		# 3. Feedback in der Konsole
		print("Bough! Rest Gold: ", GameManager.currentGold)
		print("New Strength: ", GameManager.playerStrength)
		# 4. UI sofort aktualisieren (damit der Button ggf. grau wird)
		update_ui()
		
