extends Control

# --- UI REFERENZEN ---
# Wir löschen die lokalen @onready vars für Header & Navigation, 
# da wir diese nun dynamisch aus der Main-Scene holen.

# Hero Stats & UI (Lokal in der Battle Scene)
@onready var heroName = %HeroName
@onready var heroHealthBar = %HeroHealth   
@onready var heroVisual = %HeroVisual     
@onready var heroWeaponIcon = %HeroWeaponIcon
@onready var heroArmorIcon = %HeroArmorIcon
@onready var bountyLabel = %BountyLabel

# Enemy Stats & UI (Lokal in der Battle Scene)
@onready var enemyName = %EnemyName
@onready var enemyHealthBar = %EnemyHealth
@onready var enemyVisual = %EnemyVisual
@onready var enemyWeaponIcon = %EnemyWeaponIcon
@onready var enemyArmorIcon = %EnemyArmorIcon
@onready var blackOverlay = %BlackOverlay

# Kampf-Interface (Lokal)
@onready var battleLog = %BattleLog
@onready var attackButton = %AttackButton
@onready var surrenderButton = %SurrenderButton

# --- NEUE VARIABLEN FÜR DIE HAUPT-UI ---
var main_back_btn: Button
var main_gold_label: Label

# --- SPIEL LOGIK VARIABLEN ---
var current_enemy_max_hp = 0
var current_enemy_hp = 0
var current_hero_hp = 0 
var max_hero_hp = 100

var hero_damage = 15     
var enemy_damage = 8     
var log_history = [] 
const MAX_LOG_LINES = 7 


# --- LIFECYCLE ---

func _ready():
	# 1. HAUPT-UI VERBINDEN
	# Wir suchen die Buttons in der Main-Scene über den GameManager
	if GameManager.main_node:
		# "true" bedeutet rekursive Suche (findet den Button auch in Unter-Containern)
		main_back_btn = GameManager.main_node.find_child("BtnBack", true, false)
		main_gold_label = GameManager.main_node.find_child("GoldLabel", true, false)
		
		if main_back_btn:
			# Wir kapern den Zurück-Button für den Kampf
			# Button vorübergehend UNSICHTBAR machen
			main_back_btn.visible = false
			# Wichtig: Erst alte Verbindungen trennen (falls vorhanden), damit er nicht direkt Szenen wechselt
			if main_back_btn.pressed.is_connected(GameManager.change_scene): 
				# Optional, falls du eine Standard-Funktion drauf hast. 
				# Wenn nicht, reicht das Connect unten.
				pass 
			
			# Verbinde unsere Kampf-Ende-Logik
			if not main_back_btn.pressed.is_connected(_on_btn_back_pressed):
				main_back_btn.pressed.connect(_on_btn_back_pressed)
			
		if main_gold_label:
			main_gold_label.text = "Gold: " + str(GameManager.currentGold)

	
	# 2. Kampf-Buttons verbinden
	attackButton.pressed.connect(_on_attack_button_pressed)
	surrenderButton.pressed.connect(_on_surrender_button_pressed)
	
	# 3. Held Equipment laden
	load_slot(heroWeaponIcon, "res://assets/sprites/morningstar.png")
	load_slot(heroArmorIcon, "res://assets/sprites/scale.png")
	
	# 4. Kampf vorbereiten
	if GameManager.currentEnemy:
		setupBattle(GameManager.currentEnemy)
	else:
		logText("[color=red]Error: No opponent found![/color]")

# WICHTIG: Aufräumen, wenn die Szene verlassen wird
func _exit_tree():
	# Wir müssen die Verbindung lösen, sonst feuert der Button Fehler, wenn die Battle-Scene weg ist
	if main_back_btn and main_back_btn.pressed.is_connected(_on_btn_back_pressed):
		main_back_btn.pressed.disconnect(_on_btn_back_pressed)
		main_back_btn.text = "Back to City"

# --- SETUP (Unverändert) ---

func setupBattle(enemyData):
	heroName.text = "Hero"
	current_hero_hp = GameManager.playerHp
	max_hero_hp = GameManager.playerMaxHp
	
	enemyName.text = enemyData.get("name", "Unknown")
	
	current_enemy_max_hp = enemyData.get("hp", 20)
	current_enemy_hp = current_enemy_max_hp
	enemy_damage = enemyData.get("damage", 5)
	
	var reward = enemyData.get("reward_gold", 0)
	bountyLabel.text = "BOUNTY: " + str(reward) + " GOLD"
	
	enemyHealthBar.max_value = current_enemy_max_hp
	enemyHealthBar.value = current_enemy_hp
	
	heroHealthBar.max_value = max_hero_hp
	heroHealthBar.value = current_hero_hp
	
	if "icon" in enemyData and enemyData["icon"] != null:
		enemyVisual.texture = load(enemyData["icon"])
	
	if "weapon" in enemyData:
		load_slot(enemyWeaponIcon, enemyData["weapon"])
	else:
		clear_slot(enemyWeaponIcon)
		
	if "armor" in enemyData:
		load_slot(enemyArmorIcon, enemyData["armor"])
	else:
		clear_slot(enemyArmorIcon)
		
	logText("A wild [b]" + enemyName.text + "[/b] enters the arena!")

# --- KAMPF LOGIK (Unverändert) ---

func _on_attack_button_pressed():
	attackButton.disabled = true
	surrenderButton.disabled = true
	
	var dmg = hero_damage 
	current_enemy_hp -= dmg
	
	logText("You attack for [color=green]" + str(dmg) + " damage[/color]!")
	animate_damage(enemyVisual)
	update_health_bar(enemyHealthBar, current_enemy_hp)
	
	if current_enemy_hp <= 0:
		win_battle()
		return 
	
	await get_tree().create_timer(1.0).timeout
	
	logText("The " + enemyName.text + " prepares to strike...")
	
	await get_tree().create_timer(1.0).timeout
	
	var received_dmg = enemy_damage
	current_hero_hp -= received_dmg
	
	logText("The enemy hits you for [color=red]" + str(received_dmg) + " damage[/color]!")
	if heroVisual:
		animate_damage(heroVisual)
	update_health_bar(heroHealthBar, current_hero_hp)
	
	if current_hero_hp <= 0:
		lose_battle("dead")
		return 
	
	attackButton.disabled = false
	surrenderButton.disabled = false

func _on_surrender_button_pressed():
	lose_battle("surrender")

# --- GEWINNEN / VERLIEREN (Angepasst für Main UI) ---

func win_battle():
	logText("\n[b][color=yellow]VICTORY![/color][/b]")
	logText("You stomp your enemy into the ground.")
	
	var reward = GameManager.currentEnemy.get("reward_gold", 0)
	GameManager.currentGold += reward
	
	# UPDATE: Globales Gold Label aktualisieren
	if main_gold_label:
		main_gold_label.text = "Gold: " + str(GameManager.currentGold)
	
	# UPDATE: Button einblenden und Text ändern
	if main_back_btn:
		main_back_btn.visible = true
		main_back_btn.text = "Victory! Back to City"
	
	attackButton.disabled = true
	surrenderButton.disabled = true

func lose_battle(reason):
	attackButton.disabled = true
	surrenderButton.disabled = true
	
	logText("\n[b][color=red]DEFEAT...[/color][/b]")
	
	if reason == "surrender":
		logText("You threw in the towel and ran away.")
	else:
		logText("You are severely wounded.")
		
		# UPDATE: Button einblenden und Text ändern
		if main_back_btn:
			main_back_btn.visible = true
			main_back_btn.text = "Run away..."

# --- VISUALS & ANIMATIONS (Unverändert) ---

func update_health_bar(bar: ProgressBar, new_value: int):
	var tween = create_tween()
	tween.tween_property(bar, "value", new_value, 0.4).set_trans(Tween.TRANS_SINE)

func animate_damage(target_visual: Control):
	if target_visual == null: return
	var color_tween = create_tween()
	color_tween.tween_property(target_visual, "modulate", Color(1, 0.3, 0.3), 0.1)
	color_tween.tween_property(target_visual, "modulate", Color.WHITE, 0.1)
	var shake_tween = create_tween()
	var original_pos = target_visual.position
	var strength = 5.0 
	shake_tween.tween_property(target_visual, "position:x", original_pos.x + strength, 0.05)
	shake_tween.tween_property(target_visual, "position:x", original_pos.x - strength, 0.05)
	shake_tween.tween_property(target_visual, "position:x", original_pos.x, 0.05)

func logText(text: String):
	log_history.append(text)
	if log_history.size() > MAX_LOG_LINES:
		log_history.pop_front() 
	battleLog.clear()
	for line in log_history:
		battleLog.append_text("\n" + line)

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

# --- BACK LOGIC ---

func _on_btn_back_pressed():
	# WICHTIG: Stats speichern
	GameManager.playerHp = current_hero_hp
	
	# Nachtmodus aktivieren
	GameManager.is_night = true
	
	# Zurück zur Stadt
	GameManager.change_scene("res://scenes/city_hub.tscn")
