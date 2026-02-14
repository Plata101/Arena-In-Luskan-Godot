extends Control

# --- UI REFERENZEN (Unique Names) ---
# Header & Navigation
@onready var goldLabel = %GoldLabel
@onready var btnBack = %BtnBack 

# Hero Stats & UI
@onready var heroName = %HeroName
@onready var heroHealthBar = %HeroHealth   # WICHTIG: Muss im Editor existieren!
@onready var heroVisual = %HeroVisual     # WICHTIG: Muss im Editor existieren!
@onready var heroWeaponIcon = %HeroWeaponIcon
@onready var heroArmorIcon = %HeroArmorIcon
@onready var bountyLabel = %BountyLabel

# Enemy Stats & UI
@onready var enemyName = %EnemyName
@onready var enemyHealthBar = %EnemyHealth
@onready var enemyVisual = %EnemyVisual
@onready var enemyWeaponIcon = %EnemyWeaponIcon
@onready var enemyArmorIcon = %EnemyArmorIcon
@onready var blackOverlay = %BlackOverlay

# Kampf-Interface
@onready var battleLog = %BattleLog
@onready var attackButton = %AttackButton
@onready var surrenderButton = %SurrenderButton # Tippfehler korrigiert

# --- SPIEL LOGIK VARIABLEN ---
var current_enemy_max_hp = 0
var current_enemy_hp = 0
var current_hero_hp = 0 
var max_hero_hp = 100

# Schadenswerte
var hero_damage = 15      # Festwert (später Variabel)
var enemy_damage = 8      # Wird durch setupBattle überschrieben
# Battlelog container
var log_history = [] # Ein Array für die Nachrichten
const MAX_LOG_LINES = 7 # Wie viele Zeilen du maximal willst


# --- LIFECYCLE ---

func _ready():
	# FADE IN (Vorhang auf)
	# Wir zwingen es sicherheitshalber auf Schwarz (falls im Editor vergessen)
	blackOverlay.modulate.a = 1.0 
	
	var tween = create_tween()
	# In 1.0 Sekunden von Schwarz (1) zu Transparent (0)
	tween.tween_property(blackOverlay, "modulate:a", 0.0, 0.4)
	# 1. UI Initialisieren
	if goldLabel:
		goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	if btnBack:
		btnBack.pressed.connect(_on_btn_back_pressed)
		btnBack.disabled = true # Flucht ist erst nach Sieg oder Niederlage möglich
	
	# 2. Buttons verbinden (ACHTUNG: ohne "()" am Ende!)
	attackButton.pressed.connect(_on_attack_button_pressed)
	surrenderButton.pressed.connect(_on_surrender_button_pressed)
	
	# 3. Held Equipment laden (Dummy Daten)
	load_slot(heroWeaponIcon, "res://assets/sprites/morningstar.png")
	load_slot(heroArmorIcon, "res://assets/sprites/scale.png")
	
	# 4. Kampf vorbereiten
	if GameManager.currentEnemy:
		setupBattle(GameManager.currentEnemy)
	else:
		logText("[color=red]Error: No opponent found![/color]")

# --- SETUP ---

func setupBattle(enemyData):
	# Namen setzen
	heroName.text = "Hero"
	current_hero_hp = GameManager.playerHp
	max_hero_hp = GameManager.playerMaxHp
	
	enemyName.text = enemyData.get("name", "Unknown")
	
	# Interne Variablen setzen
	current_enemy_max_hp = enemyData.get("hp", 20)
	current_enemy_hp = current_enemy_max_hp
	enemy_damage = enemyData.get("damage", 5)
	
	# Bounty / Reward anzeigen
	var reward = enemyData.get("reward_gold", 0)
	bountyLabel.text = "BOUNTY: " + str(reward) + " GOLD"
	
	# Health Bars initialisieren
	enemyHealthBar.max_value = current_enemy_max_hp
	enemyHealthBar.value = current_enemy_hp
	
	heroHealthBar.max_value = max_hero_hp
	heroHealthBar.value = current_hero_hp
	
	# Gegner Bild laden
	if "icon" in enemyData and enemyData["icon"] != null:
		enemyVisual.texture = load(enemyData["icon"])
	
	# Gegner Equipment laden
	if "weapon" in enemyData:
		load_slot(enemyWeaponIcon, enemyData["weapon"])
	else:
		clear_slot(enemyWeaponIcon)
		
	if "armor" in enemyData:
		load_slot(enemyArmorIcon, enemyData["armor"])
	else:
		clear_slot(enemyArmorIcon)
		
	# Startnachricht
	logText("A wild [b]" + enemyName.text + "[/b] enters the arena!")

# --- KAMPF LOGIK (RUNDENBASIERT) ---

func _on_attack_button_pressed():
	# Buttons sperren, damit Spieler nicht spammen kann
	attackButton.disabled = true
	surrenderButton.disabled = true
	
	# --- RUNDE 1: HELD GREIFT AN ---
	var dmg = hero_damage # Hier später Random (z.B. randi_range(10, 15))
	current_enemy_hp -= dmg
	
	# Visuelles Feedback
	logText("You attack for [color=green]" + str(dmg) + " damage[/color]!")
	animate_damage(enemyVisual)
	update_health_bar(enemyHealthBar, current_enemy_hp)
	
	# Check: Gegner besiegt?
	if current_enemy_hp <= 0:
		win_battle()
		return # Funktion beenden, Gegner ist tot
	
	# Kurze Pause für Spannung (1 Sekunde)
	await get_tree().create_timer(1.0).timeout
	
	# --- RUNDE 2: GEGNER GREIFT AN ---
	logText("The " + enemyName.text + " prepares to strike...")
	
	# Pause für Reaktion
	await get_tree().create_timer(1.0).timeout
	
	var received_dmg = enemy_damage
	current_hero_hp -= received_dmg
	
	# Visuelles Feedback
	logText("The enemy hits you for [color=red]" + str(received_dmg) + " damage[/color]!")
	if heroVisual:
		animate_damage(heroVisual)
	update_health_bar(heroHealthBar, current_hero_hp)
	
	# Check: Held besiegt?
	if current_hero_hp <= 0:
		lose_battle("dead")
		return # Funktion beenden
	
	# --- ENDE DER RUNDE ---
	# Buttons wieder freigeben
	attackButton.disabled = false
	surrenderButton.disabled = false

func _on_surrender_button_pressed():
	lose_battle("surrender")

# --- GEWINNEN / VERLIEREN ---

func win_battle():
	logText("\n[b][color=yellow]VICTORY![/color][/b]")
	logText("You stomp your enemy into the ground.")
	
	# Belohnung
	var reward = GameManager.currentEnemy.get("reward_gold", 0)
	GameManager.currentGold += reward
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	# Navigation aktivieren
	btnBack.disabled = false
	btnBack.text = "Return to City like a king"
	
	# Kampf Buttons deaktiviert lassen
	attackButton.disabled = true
	surrenderButton.disabled = true

func lose_battle(reason):
	attackButton.disabled = true
	surrenderButton.disabled = true
	
	logText("\n[b][color=red]DEFEAT...[/color][/b]")
	
	if reason == "surrender":
		logText("You threw in the towel and ran away.")
	else:
		logText("You are severely wounded and drag yourself out of the arena.")
	
	btnBack.disabled = false
	btnBack.text = "Limp back to City"

# --- VISUALS & ANIMATIONS ---

func update_health_bar(bar: ProgressBar, new_value: int):
	# Erstellt eine flüssige Animation des Balkens
	var tween = create_tween()
	tween.tween_property(bar, "value", new_value, 0.4).set_trans(Tween.TRANS_SINE)

func animate_damage(target_visual: Control):
	if target_visual == null: return
	
	# 1. Rot aufblitzen
	var color_tween = create_tween()
	color_tween.tween_property(target_visual, "modulate", Color(1, 0.3, 0.3), 0.1)
	color_tween.tween_property(target_visual, "modulate", Color.WHITE, 0.1)
	
	# 2. Wackeln (Shake)
	var shake_tween = create_tween()
	var original_pos = target_visual.position
	var strength = 5.0 # Stärke in Pixeln
	
	shake_tween.tween_property(target_visual, "position:x", original_pos.x + strength, 0.05)
	shake_tween.tween_property(target_visual, "position:x", original_pos.x - strength, 0.05)
	shake_tween.tween_property(target_visual, "position:x", original_pos.x, 0.05)

func logText(text: String):
	# 1. Neue Nachricht ins Array packen
	log_history.append(text)
	
	# 2. Prüfen, ob wir zu viele haben (Array.size() statt .length)
	if log_history.size() > MAX_LOG_LINES:
		log_history.pop_front() # Das älteste Element löschen (wie shift())
	
	# 3. Das Textfeld leeren und neu befüllen
	battleLog.clear()
	
	for line in log_history:
		# Wir fügen jede Zeile aus dem Gedächtnis wieder ein
		battleLog.append_text("\n" + line)

# --- HELPER FUNCTIONS ---

func load_slot(icon_node: TextureRect, path: String):
	if icon_node == null: return
	
	if path and ResourceLoader.exists(path):
		icon_node.texture = load(path)
		icon_node.visible = true
	else:
		icon_node.texture = null

func clear_slot(icon_node: TextureRect):
	if icon_node:
		icon_node.texture = null

func _on_btn_back_pressed():
		# 1. Maus blockieren
	if blackOverlay: blackOverlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fade Out (Schwarz werden) - SCHNELLER (0.4s)
	var tween = create_tween()
	if blackOverlay:
		tween.tween_property(blackOverlay, "modulate:a", 1.0, 0.4)
		await tween.finished
	GameManager.playerHp = current_hero_hp
	# Wenn wir die Arena verlassen, wird es Nacht!
	GameManager.is_night = true
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
