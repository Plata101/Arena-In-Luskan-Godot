extends Control

@onready var goldLabel = %GoldLabel
@onready var btnBack = %BtnBack 
@onready var enemyName = %EnemyName
@onready var enemyHealthBar = %EnemyHealth
@onready var enemyVisual = %EnemyVisual
@onready var battleLog = %BattleLog
@onready var attackButton = %AttackButton

@onready var heroName = %HeroName


func _ready():
	
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
	
	# Bild setzten
	if "icon" in enemyData and enemyData["icon"] != null:
		# WICHTIG: Wir müssen den Pfad (String) laden!
		enemyVisual.texture = load(enemyData["icon"])
		
	# Start message
	logText("A wild [b]" + enemyName.text + "[/b] enters the arena!")


func logText(text: String):
	battleLog.append_text("\n" + text)

func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")


func _on_attack_button_pressed():
		logText("You attack! (Logik folgt...)")
