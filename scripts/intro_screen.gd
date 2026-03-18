extends Control

# --- UI REFERENZEN ---
@onready var loreContainer = %LoreContainer
@onready var loreText = %LoreText
@onready var btnContinue = %BtnContinue

@onready var nameContainer = %NameContainer
@onready var nameInput = %NameInput
@onready var btnConfirmName = %BtnConfirmName

@onready var classContainer = %ClassContainer
@onready var btnWarrior = %BtnWarrior
@onready var btnThief = %BtnThief
@onready var btnBrawler = %BtnBrawler

var lore_string = "So you arrived at the city in the kingdom of Oakhaven...\n\nThe once noble king turned sour in the past years, now rules the country with an iron hand and is always on campaigning to expand his lands. To keep the masses at bay and entertain them, daily fights are staged in the arena called The Gauntlet."

func _ready():
	# 1. Start-Zustand: Alles verstecken außer Lore
	nameContainer.visible = false
	classContainer.visible = false
	
	btnContinue.visible = false
	btnContinue.modulate.a = 0.0 # Für den Fade-In später
	
	loreText.text = "[center]" + lore_string + "[/center]"
	
	# 2. Buttons verknüpfen
	btnContinue.pressed.connect(_on_continue_pressed)
	btnConfirmName.pressed.connect(_on_confirm_name_pressed)
	
	# Die bind() Funktion ist genial: Sie sagt der Funktion direkt, WELCHER Button geklickt wurde!
	btnWarrior.pressed.connect(choose_class.bind("Warrior"))
	btnThief.pressed.connect(choose_class.bind("Thief"))
	btnBrawler.pressed.connect(choose_class.bind("Brawler"))
	
	# 3. Action!
	start_intro()

func start_intro():
	print("start")
	loreContainer.visible = true
	loreText.visible_ratio = 0.0
	
	# Für Intros darf der Text gerne etwas langsamer laufen (z.B. 0.04 statt 0.02)
	var visible_chars = loreText.get_parsed_text().length()
	var type_duration = visible_chars * 0.04 
	
	var tween = create_tween()
	tween.tween_property(loreText, "visible_ratio", 1.0, type_duration)
	
	# Sobald der Text fertig ist, taucht sanft der Continue-Button auf
	tween.tween_callback(func(): btnContinue.visible = true)
	tween.tween_property(btnContinue, "modulate:a", 1.0, 1.0)

# --- PHASE 2: NAME ---
func _on_continue_pressed():
	loreContainer.visible = false
	nameContainer.visible = true

# --- PHASE 3: KLASSENWAHL ---
func _on_confirm_name_pressed():
	print("Button wurde geklickt! Eingegebener Name: '", nameInput.text, "'")
	
	# Verhindern, dass der Spieler keinen Namen eingibt
	if nameInput.text.strip_edges() == "":
		print("ABBRUCH: Das Textfeld wird als leer erkannt!")
		return 
		
	# Name im GameManager speichern!
	GameManager.player_name = nameInput.text.strip_edges()
	print("Erfolg! Schalte auf Klassenauswahl um...")
	
	nameContainer.visible = false
	classContainer.visible = true

# --- ENDE: AB IN DIE STADT ---
func choose_class(chosen_class: String):
	print("Player chose: ", chosen_class)
	
	# Werte im GameManager setzen
	GameManager.setup_player(chosen_class)
	
	# Wechsel zur Stadt (Pfad evtl. anpassen!)
	if GameManager.main_node:
		GameManager.main_node.change_scene("res://scenes/city_hub.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
