extends Control

# --- REFERENZEN ---
@onready var btnClose = %BtnClose # Dein X-Button

# Mittlere Spalte (Stats)
@onready var hpLabel = %HpValueLabel 
@onready var enduranceLabel = %EnduranceValueLabel
@onready var apLabel = %ActionPointsValueLabel
@onready var armorLabel = %ArmorClassValueLabel

@onready var strLabel = %StrengthValueLabel
@onready var staLabel = %StaminaValueLabel
@onready var dexLabel = %DexterityValueLabel
@onready var luckLabel = %LuckValueLabel

@onready var goldLabel = %GoldValueLabel


func _ready():
	# 1. Close Button verbinden
	if btnClose:
		btnClose.pressed.connect(_on_close_pressed)
	
	# 2. Werte aktualisieren
	update_stats()

func update_stats():
	# Füllt die Labels mit den globalen Werten
	# (Wir wandeln die Integers mit str() in Text um)
	
	hpLabel.text = str(GameManager.playerHp) + " / " + str(GameManager.playerMaxHp)
	enduranceLabel.text = str(GameManager.playerEndurance) + " / " + str(GameManager.playerMaxEndurance)
	apLabel.text = str(GameManager.playerActionPoints)
	armorLabel.text = str(GameManager.playerArmorClass)
	
	strLabel.text = str(GameManager.playerStrength)
	staLabel.text = str(GameManager.playerStamina)
	dexLabel.text = str(GameManager.playerDexterity)
	luckLabel.text = str(GameManager.playerLuck)
	
	goldLabel.text = str(GameManager.currentGold)

func _on_close_pressed():
	# Overlay löschen/schließen
	queue_free()
