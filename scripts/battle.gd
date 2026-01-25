extends Control

@onready var goldLabel = %GoldLabel
@onready var btnBack = %BtnBack 
@onready var enemyName = %EnemyName
@onready var enemyHealthBar = %EnemyHealth
@onready var enemyVisual = %EnemyVisual
@onready var heroWeaponIcon = %HeroWeaponIcon
@onready var heroArmorIcon = %HeroArmorIcon
@onready var enemyWeaponIcon = %EnemyWeaponIcon
@onready var enemyArmorIcon = %EnemyArmorIcon


@onready var battleLog = %BattleLog
@onready var attackButton = %AttackButton

@onready var heroName = %HeroName


func _ready():
	
		# HELD EQUIPMENT LADEN (Dummy Daten für MVP)
	# Später holen wir das aus GameManager.player_equipment
	load_slot(heroWeaponIcon, "res://assets/sprites/morningstar.png")
	load_slot(heroArmorIcon, "res://assets/sprites/scale.png")
	
	
	if goldLabel:
		goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	if btnBack:
		btnBack.pressed.connect(_on_btn_back_pressed)
		
	if GameManager.currentEnemy:
		setupBattle(GameManager.currentEnemy)
	else:
		logText("[color=red]No opponent found![/color]")
		

func setupBattle(enemyData):
	# Namen setzen
	heroName.text = "Hero"
	enemyName.text = enemyData.get("name", "Unknown")
	
	# HP setzen
	var maxHp = enemyData.get("hp", 10)
	enemyHealthBar.max_value = maxHp
	enemyHealthBar.value = maxHp
	
	# Bild / Rüstung setzten
	if "icon" in enemyData and enemyData["icon"] != null:
		# WICHTIG: Wir müssen den Pfad (String) laden!
		enemyVisual.texture = load(enemyData["icon"])
	
	# GEGNER EQUIPMENT LADEN
	# Wir nutzen eine Hilfsfunktion, falls kein Icon da ist
	if "weapon" in enemyData:
		load_slot(enemyWeaponIcon, enemyData["weapon"])
	else:
		clear_slot(enemyWeaponIcon)
		
	if "armor" in enemyData:
		load_slot(enemyArmorIcon, enemyData["armor"])
	else:
		clear_slot(enemyArmorIcon)
		
	# Start message
	logText("A wild [b]" + enemyName.text + "[/b] enters the arena!")


# HELPER FUNCTIONS

func load_slot(icon_node: TextureRect, path: String):
	print("Versuche Slot zu laden: ", path) # DEBUG
	if path and ResourceLoader.exists(path):
		icon_node.texture = load(path)
		icon_node.visible = true
	else:
		# Falls Pfad falsch oder leer -> Slot leer anzeigen
		icon_node.texture = null

func clear_slot(icon_node: TextureRect):
	icon_node.texture = null



# LOG


func logText(text: String):
	battleLog.append_text("\n" + text)


# BUTTONS

func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")

func _on_attack_button_pressed():
	animateDamage(enemyVisual)
	logText("You attack! (Logik folgt...)")


# ANIMATIONS

func animateDamage(target_visual: Control):
	# Einen neuen "Tween" (Zwischenbild-Berechner) erstellen
	var tween = create_tween()
	
	# 1. Rot aufblitzen (Modulate Farbe ändern)
	# Von normal (weiss) zu rot in 0.1 sekunden
	tween.tween_property(target_visual, "modulate", Color(1, 0.3, 0.3), 0.1)
	# Und wieder zurück zu weiss
	tween.tween_property(target_visual, "modulate", Color.WHITE, 0.1)
	
	# 2. Wackeln (Parallel dazu)
	# Da wir "shake" wollen, machen wir das etwas manueller oder simpler:
	# Wir schieben das Bild kurz nach rechts und links
	var shake_tween = create_tween()
	var original_pos = target_visual.position # Die aktuelle Position merken
	var strength = 2.0 # Wie stark es wackelt (in Pixeln)
	
	# Schritt 1: Nach rechts schieben (in 0.05 Sek)
	shake_tween.tween_property(target_visual, "position:x", original_pos.x + strength, 0.05)
	# Schritt 2: Nach links schieben (über die Mitte hinaus)
	shake_tween.tween_property(target_visual, "position:x", original_pos.x - strength, 0.05)
	# Schritt 3: Wieder zurück zur Original-Position
	shake_tween.tween_property(target_visual, "position:x", original_pos.x, 0.05)
