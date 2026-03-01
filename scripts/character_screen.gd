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

@onready var weaponsList = %WeaponsList
@onready var potionsList = %PotionsList
@onready var miscList = %MiscList

func _ready():
	# 1. Close Button verbinden
	if btnClose:
		btnClose.pressed.connect(_on_close_pressed)
	
	# 2. Werte aktualisieren
	update_stats()
	populate_inventory()

func update_stats():
	# 1. Basiswerte aus dem GameManager holen
	var current_str = GameManager.playerStrength
	var current_armor = GameManager.playerArmorClass
	
	# 2. Boni auslesen (falls etwas ausgerüstet ist)
	var str_bonus = 0
	if GameManager.equipped_weapon != null:
		# Holt den Wert "bonus" aus dem Item-Dictionary (Standard ist 0, falls keiner existiert)
		str_bonus = GameManager.equipped_weapon.get("bonus", 0)
		
	var armor_bonus = 0
	if GameManager.equipped_armor != null:
		armor_bonus = GameManager.equipped_armor.get("bonus", 0)
		
	# 3. Gesamtwerte berechnen
	var total_str = current_str + str_bonus
	var total_armor = current_armor + armor_bonus

	# --- LABELS AKTUALISIEREN ---
	
	# Standard-Labels
	hpLabel.text = str(GameManager.playerHp) + " / " + str(GameManager.playerMaxHp)
	enduranceLabel.text = str(GameManager.playerEndurance) + " / " + str(GameManager.playerMaxEndurance)
	apLabel.text = str(GameManager.playerActionPoints)
	
	# Rüstungsklasse: Zeigt "14 (+4)" an, wenn eine Rüstung mit +4 ausgerüstet ist
	if armor_bonus > 0:
		armorLabel.text = str(total_armor) + " (+" + str(armor_bonus) + ")"
		armorLabel.modulate = Color(0.5, 1.0, 0.5) # Mach den Text grünlich zur Belohnung
	else:
		armorLabel.text = str(total_armor)
		armorLabel.modulate = Color.WHITE # Normale Farbe
		
	# Stärke: Analog zur Rüstung
	if str_bonus > 0:
		strLabel.text = str(total_str) + " (+" + str(str_bonus) + ")"
		strLabel.modulate = Color(0.5, 1.0, 0.5) 
	else:
		strLabel.text = str(total_str)
		strLabel.modulate = Color.WHITE

	# Restliche Stats bleiben wie sie sind
	staLabel.text = str(GameManager.playerStamina)
	dexLabel.text = str(GameManager.playerDexterity)
	luckLabel.text = str(GameManager.playerLuck)
	
func populate_inventory():
	# 1. Alte Listen leeren
	for child in weaponsList.get_children(): child.queue_free()
	for child in potionsList.get_children(): child.queue_free()
	for child in miscList.get_children(): child.queue_free()
	
	# 2. Durch GameManager iterieren
	for item in GameManager.inventory:
		# Erstelle neue Zeile (Horizontal Box)
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 45) # Etwas mehr Höhe pro Zeile
		
		# --- NEU 1: ABSTAND ZWISCHEN DEN ELEMENTEN ---
		# Fügt automatisch 15 Pixel Abstand zwischen Bild, Text und Button ein.
		row.add_theme_constant_override("separation", 15)
		
		# --- NEU 2: PADDING NACH LINKS (Indentation) ---
		# Wir fügen ein leeres Control-Element als erstes Kind hinzu.
		# Es ist 10 Pixel breit und drückt den Rest nach rechts.
		var left_indent = Control.new()
		left_indent.custom_minimum_size.x = 10 
		row.add_child(left_indent)
		
		# A) Das Icon
		var icon = TextureRect.new()
		if ResourceLoader.exists(item["icon"]):
			icon.texture = load(item["icon"])
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# B) Der Name des Items
		var name_label = Label.new()
		name_label.text = item["name"]
		# Das hier lassen wir so: Es füllt den Platz in der Mitte aus.
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		
		# --- TIPP: KLEINERE SCHRIFT ---
		# Optional: Wenn die Schrift zu groß wirkt, können wir sie kleiner machen.
		# name_label.add_theme_font_size_override("font_size", 14) 
		
		# C) Der Equip / Use Button
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 0) # Button etwas breiter
		
		if GameManager.equipped_weapon == item or GameManager.equipped_armor == item:
			btn.text = "E" 
			btn.modulate = Color(0.5, 1.0, 0.5)
		else:
			btn.text = "Equip"
		
		btn.pressed.connect(_on_item_action_pressed.bind(item))
		
		# D) Alles in die Zeile packen (Reihenfolge ist wichtig!)
		row.add_child(icon)
		row.add_child(name_label)
		# --- NEU 3: PADDING NACH RECHTS ---
		# Optional: Wir können auch ein Control am Ende einfügen, 
		# um Abstand zum Scrollbar-Rand zu halten.
		var right_indent = Control.new()
		right_indent.custom_minimum_size.x = 5 
		
		row.add_child(btn)
		row.add_child(right_indent) # <--- Abstandhalter am Ende
		
		# E) Einsortieren (WICHTIG: Pfade prüfen!)
		# Der Screenshot zeigt: Node heißt "WeaponList" (Einzahl).
		var type = item.get("type", "")
		if type == "Strength" or type == "Armor":
			weaponsList.add_child(row) 
		elif type == "Potion":
			potionsList.add_child(row)
		else:
			miscList.add_child(row)

func _on_item_action_pressed(item_data):
	var type = item_data.get("type", "")
	
	# Waffe ausrüsten
	if type == "Strength":
		# Wenn es schon ausgerüstet ist, ziehen wir es wieder aus
		if GameManager.equipped_weapon == item_data:
			GameManager.equipped_weapon = null
		else:
			GameManager.equipped_weapon = item_data
			
	# Rüstung ausrüsten
	elif type == "Armor":
		if GameManager.equipped_armor == item_data:
			GameManager.equipped_armor = null
		else:
			GameManager.equipped_armor = item_data
	
	# UI neu laden, damit die Buttons (das grüne "E") aktualisiert werden
	populate_inventory()
	# Später fügen wir hier noch hinzu, dass sich deine Stats ändern!
	update_stats()


func _on_close_pressed():
	# Overlay löschen/schließen
	queue_free()
