extends Control

#UI Referenzen
@onready var enemyListContainer = %EnemyList
@onready var enemyNameLabel = %EnemyNameLabel
@onready var enemyImage = %EnemyImage
@onready var enemyStatsLabel = %EnemyStatsLabel
@onready var dangerLabel = %DangerLabel	
@onready var fightButton = %BtnFight

@onready var goldLabel = %GoldLabel
@onready var descriptionLabel = %DescriptionLabel 

# Der aktuell gewählte Gegner
var selectedEnemyData = {}

# Monster-Datenbank / JSON later
var enemies = [
	{
		"id": "goblin",
		"name": "Goblin Scout",
		"hp": 20,
		"damage": 3,
		"reward_gold": 10,
		"icon": "res://assets/sprites/monsters/goblin.png", # Pfad anpassen!
		"weapon": "res://assets/sprites/items/dagger.png", # Beispielpfad!
		"armor": "res://assets/sprites/items/leather.png",
		"loot_chance": 0.3, # 30% Chance das zu droppen
		"min_level": 1, # Optional: Erst ab Level X sichtbar
		"description": "A small but sneaky thief lurking in the shadows. He would rather steal than fight."
	},
	{
		"id": "orc_grunt",
		"name": "Ork Warrior",
		"hp": 45,
		"damage": 6,
		"reward_gold": 25,
		"icon": "res://assets/sprites/monsters/orc.png",
		"weapon": "res://assets/sprites/items/axe.png",
		"armor": "res://assets/sprites/items/plate.png",
		"loot_chance": 0.3, # 30% Chance das zu droppen
		"min_level": 1,
		"description": "A brutal soldier of the Horde. His axe is rusty, but deadly. He smells like old cheese and violence."
	},
	{
		"id": "troll",
		"name": "Cave Troll",
		"hp": 200,
		"damage": 12,
		"reward_gold": 100,
		"icon": "res://assets/sprites/monsters/troll.png",
		"weapon": "res://assets/sprites/items/claw.png",
		"armor": "res://assets/sprites/items/scale.png",
		"loot_chance": 0.3, # 30% Chance das zu droppen
		"min_level": 1,
		"description": "A massive monster from the depths. His skin is as hard as stone. Only the bravest dare approach him."
	}
]

func _ready():
	
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
			btn.text = " " + enemy["name"]
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT # Text links im Button
			
			# --- HIER IST DIE ÄNDERUNG ---
			# 1. Wir geben dem Button eine feste Mindestgröße (Breite x Höhe)
			# 250 Pixel breit, 40 Pixel hoch (pass den Wert an, wie du magst)
			btn.custom_minimum_size = Vector2(250, 40)
			
			# 2. Damit er nicht breiter wird als 250px (falls der Container riesig ist),
			# sagen wir ihm: "Bleib links und nimm nicht mehr Platz als nötig"
			btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN 
			
			btn.pressed.connect(select_enemy.bind(enemy))
			enemyListContainer.add_child(btn)
		
		
func select_enemy(data):
	selectedEnemyData = data
	
	# UI Update
	enemyNameLabel.text = "[i]" + data["name"] + "[/i]"
	enemyStatsLabel.text = "HP: " + str(data["hp"]) + " | Damage: " + str(data["damage"]) + "\nReward: " + str(data["reward_gold"]) + " Gold"
	
	descriptionLabel.text = "[i]" + data["description"] + "[/i]"
	
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
		dangerLabel.text = "Danger: DEADLY 💀"
		dangerLabel.modulate = Color(1, 0, 0) # Rot
	elif damageTaken >= playerSurvivability * 0.7:
		dangerLabel.text = "Danger: HIGH ⚠️"
		dangerLabel.modulate = Color(1, 0.5, 0) # Orange
	else:
		dangerLabel.text = "Danger: Low ✅"
		dangerLabel.modulate = Color(0, 1, 0) # Grün

func _on_btn_fight_pressed():
	# Hier übergeben wir den Gegner an den GameManager, damit die Battle-Szene weiß, wer dran ist
	# Das bauen wir gleich in Schritt 3 ein!
	GameManager.currentEnemy = selectedEnemyData
	
	# Szenenwechsel
	GameManager.change_scene("res://scenes/battle.tscn")
