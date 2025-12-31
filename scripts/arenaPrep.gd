extends Control

#UI Referenzen
@onready var enemyListContainer = %EnemyList
@onready var enemyNameLabel = %EnemyNameLabel
@onready var enemyImage = %EnemyImage
@onready var enemyStatsLabel = %EnemyStatsLabel
@onready var dangerLabel = %DangerLabel
@onready var fightButton = %BtnFight

@onready var goldLabel = %GoldLabel 
@onready var btnBack = %BtnBack # Falls du dem Button im Header diesen Unique Name gegeben hast

# Der aktuell gewählte Gegner
var selectedEnemyData = {}

# Monster-Datenbank / JSON later
var enemies = [
	{
		"id": "goblin",
		"name": "Goblin Späher",
		"hp": 20,
		"damage": 3,
		"reward_gold": 10,
		"icon": "res://assets/sprites/goblin.png", # Pfad anpassen!
		"min_level": 1 # Optional: Erst ab Level X sichtbar
	},
	{
		"id": "orc_grunt",
		"name": "Ork Krieger",
		"hp": 45,
		"damage": 6,
		"reward_gold": 25,
		"icon": "res://assets/sprites/orc.png",
		"min_level": 1
	},
	{
		"id": "troll",
		"name": "Höhlentroll",
		"hp": 100,
		"damage": 12,
		"reward_gold": 100,
		"icon": "res://assets/sprites/troll.png",
		"min_level": 1
	}
]

func _ready():
	
	# 1. Header Updates (Gold anzeigen)
	if goldLabel:
		goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	# 2. Back Button verbinden
	# Prüfen ob der Button da ist, um Abstürze zu vermeiden
	if btnBack:
		btnBack.pressed.connect(_on_btn_back_pressed)
	
	
	generate_enemy_buttons()
	
	# Wähle ersten Gegner aut. damit UI nicht leer ist
	if not enemies.is_empty():
		select_enemy(enemies[0])
		
func generate_enemy_buttons():
	# clean up
	for child in enemyListContainer.get_children():
		child.queue_free()
	for enemy in enemies:
		var btn = Button.new()
		btn.text = enemy["name"] 
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT # Sieht hübscher aus
		
		# WICHTIG: Verbinden und Daten mitgeben (.bind)
		btn.pressed.connect(select_enemy.bind(enemy))
		
		enemyListContainer.add_child(btn)
		
		
func select_enemy(data):
	selectedEnemyData = data
	
	# UI Update
	enemyNameLabel.text = data["name"]
	enemyStatsLabel.text = "HP: " + str(data["hp"]) + " | Schaden: " + str(data["damage"]) + "\nBelohnung: " + str(data["reward_gold"]) + " Gold"
	
	# Bild laden (Safety Check)
	if ResourceLoader.exists(data["icon"]):
		enemyImage.texture = load(data["icon"])
	else:
		enemyImage.texture = load("res://icon.svg") # Platzhalter
	
	calculate_danger_level(data)
	
func calculate_danger_level(data):
	# Ein simpler Algorithmus um zu sagen "Schaffst du das?"
	# Wir vergleichen Player "Power" (HP + Str + Armor) mit Enemy "Power"
	
	# Angenommen Player HP ist fix oder im GameManager (z.B. 20 base + level * 5)
	# Hier eine vereinfachte Rechnung:
	var playerSurvivability = 20 + GameManager.playerArmor * 2 # Wie viel hält der Spieler aus?
	var playerDamageOutput = GameManager.playerStrength
	
	# Wie viele Runden braucht der Spieler? (EnemyHP / PlayerDmg)
	var turnsToKill = float(data["hp"]) / float(playerDamageOutput)
	
	# Wie viel Schaden macht der Gegner in dieser Zeit?
	var damageTaken = turnsToKill * data["damage"]
	
	# Wenn wir mehr Schaden fressen als wir Leben haben -> Tödlich
	if damageTaken >= playerSurvivability:
		dangerLabel.text = "Gefahr: TÖDLICH 💀"
		dangerLabel.modulate = Color(1, 0, 0) # Rot
	elif damageTaken >= playerSurvivability * 0.7:
		dangerLabel.text = "Gefahr: Hoch ⚠️"
		dangerLabel.modulate = Color(1, 0.5, 0) # Orange
	else:
		dangerLabel.text = "Gefahr: Einfach ✅"
		dangerLabel.modulate = Color(0, 1, 0) # Grün

func _on_btn_fight_pressed():
	# Hier übergeben wir den Gegner an den GameManager, damit die Battle-Szene weiß, wer dran ist
	# Das bauen wir gleich in Schritt 3 ein!
	GameManager.currentEnemy = selectedEnemyData
	
	# Szenenwechsel
	# get_tree().change_scene_to_file("res://scenes/Battle.tscn")
	print("Kampf startet gegen: " + selectedEnemyData["name"])

func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
