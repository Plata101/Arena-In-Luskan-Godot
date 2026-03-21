extends Control

# --- UI REFERENZEN ---
@onready var loreContainer = %LoreContainer
@onready var loreText = %LoreText
@onready var gauntletLogo = %GauntletLogo
@onready var btnContinue = %BtnContinue

@onready var nameContainer = %NameContainer
@onready var nameInput = %NameInput
@onready var btnConfirmName = %BtnConfirmName

@onready var classContainer = %ClassContainer
@onready var classStatsPanel = %ClassStatsPanel
@onready var classStatsLabel = %ClassStatsLabel

@onready var btnWarrior = %BtnWarrior
@onready var btnThief = %BtnThief
@onready var btnBrawler = %BtnBrawler

# --- CHARAKTER DATEN ---
var char_data = {
	"Warrior": {
		"gold": 100, "hp": 100, "end": 150, "str": 6, "stam": 6, "dex": 4, "luck": 2, "alignment": 'Neutral',
		"story": "[indent][i]A former castle guard, discarded from duty because of peeping on the princess in her bedroom, you are lucky not to have been executed. Without any income and your last savings in your pocket you made camp in the dragon's tankard in the city. The innkeeper owes you, because you let him slip on missing curfew so many times. So you can stay here for the time being. You arrive at your chamber, putting your leather armor and short sword in a corner and the only idea you have, is fighting in the gauntlet to make enough gold to survive.[/i][/indent]\n\n[center][b]Main Quest:[/b][/center]\n[center]Get a date with the princess[/center]"
	},
	"Thief": {
		"gold": 200, "hp": 80, "end": 120, "str": 3, "stam": 4, "dex": 6, "luck": 6, "alignment": 'Evil',
		"story": "[indent][i]Your thieving days are over. You've been caught one too many times and people know your face too well. Time to switch your profession and change your lookpicks for a sword. Fortunately you are well stacked from you last job and at least can afford some gear before entering into deadly combat. A room in the dragon's tankard is your homebase. You steal back the 10 Gold daily cost every time the naive innkeeper collects, so you are renting for free. Also your connections gives you more frequent access to the black market. You start with a dagger.[/i][/indent]\n\n[center][b]Main Quest:[/b][/center]\n[center]Loot the kings treasure chamber[/center]"
	},
	"Brawler": {
		"gold": 50, "hp": 150, "end": 200, "str": 7, "stam": 7, "dex": 3, "luck": 4, "alignment": 'Good',
		"story": "[indent][i]Oh well, that last campaign was too much for your knight, he was killed in combat and you barely made it limping back to the city yourself, forgotten by your peers. Much worse, your family has left the city and sold the estate, thinking you were killed. No knight has any use for a squire like you, so you deceide to take whatever fighting skills you learned along your service and make a name for yourself in the arena. Since you have no home, you set up in the dragon's tankard, a pricey endevour, but its worth to have a roof over your head. Your stard with your formers master scale armor and his broadsword.[/i][/indent]\n\n[center][b]Main Quest:[/b][/center]\n[center]Become the Grand Champion of the Gauntlet to restore your family's honor[/center]"
	}
}

var lore_string = "So you arrived at the city in the kingdom of Oakhaven...\n\nThe once noble king turned sour in the past years, now rules the country with an iron hand and is always on campaigning to expand his lands. To keep the masses at bay and entertain them, daily fights are staged in the arena called..."

func _ready():
	# 1. Start-Zustand aufräumen
	loreContainer.visible = true
	loreText.visible = true
	
	nameContainer.visible = false
	classContainer.visible = false
	gauntletLogo.visible = false
	classStatsPanel.visible = false
	
	btnContinue.visible = false
	btnContinue.modulate.a = 0.0
	
	# Text vorbereiten
	loreText.text = "[center]" + lore_string + "[/center]"
	
	# 2. Buttons verknüpfen
	btnContinue.pressed.connect(_on_continue_pressed)
	btnConfirmName.pressed.connect(_on_confirm_name_pressed)
	
	btnWarrior.pressed.connect(choose_class.bind("Warrior"))
	btnThief.pressed.connect(choose_class.bind("Thief"))
	btnBrawler.pressed.connect(choose_class.bind("Brawler"))
	
	# 3. Hover-Effekte verknüpfen
	btnWarrior.mouse_entered.connect(_on_class_hover_started.bind("Warrior"))
	btnThief.mouse_entered.connect(_on_class_hover_started.bind("Thief"))
	btnBrawler.mouse_entered.connect(_on_class_hover_started.bind("Brawler"))
	
	btnWarrior.mouse_exited.connect(_on_class_hover_ended)
	btnThief.mouse_exited.connect(_on_class_hover_ended)
	btnBrawler.mouse_exited.connect(_on_class_hover_ended)
	
	# 4. Action!
	start_intro()

func start_intro():
	loreText.visible_ratio = 0.0
	gauntletLogo.visible = false
	gauntletLogo.modulate.a = 0.0
	
	var visible_chars = loreText.get_parsed_text().length()
	var type_duration = visible_chars * 0.04 
	
	var tween = create_tween()
	
	# Aktion A: Text rattert durch
	tween.tween_property(loreText, "visible_ratio", 1.0, type_duration)
	
	# Aktion B: Kurze Pause
	tween.tween_interval(1.0)
	
	# Aktion C: Logo fadet ein
	tween.tween_callback(func(): gauntletLogo.visible = true)
	tween.tween_property(gauntletLogo, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	
	# Aktion D: Continue Button taucht auf
	tween.tween_callback(func(): btnContinue.visible = true)
	tween.tween_property(btnContinue, "modulate:a", 1.0, 0.5)

# --- PHASE 2: NAME ---
func _on_continue_pressed():
	# Wir faden den Text und den Button aus, das Logo lassen wir stehen!
	var tween = create_tween()
	tween.parallel().tween_property(loreText, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(btnContinue, "modulate:a", 0.0, 0.4)
	
	tween.tween_callback(func():
		loreText.visible = false
		btnContinue.visible = false
		
		# Namensfeld einschalten und vorbereiten
		nameContainer.visible = true
		nameContainer.modulate.a = 0.0
	)
	nameInput.grab_focus()
	
	# Namensfeld einfaden
	tween.tween_property(nameContainer, "modulate:a", 1.0, 0.5)

# --- PHASE 3: KLASSENWAHL ---
func _on_confirm_name_pressed():
	if nameInput.text.strip_edges() == "":
		return 
		
	GameManager.player_name = nameInput.text.strip_edges()
	
	# Container vorbereiten
	classContainer.visible = true
	classContainer.modulate.a = 0.0
	
	var tween = create_tween()
	
	# Logo und Namensfeld sanft ausfaden
	tween.parallel().tween_property(nameContainer, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(gauntletLogo, "modulate:a", 0.0, 0.4)
	
	tween.tween_callback(func():
		nameContainer.visible = false
		gauntletLogo.visible = false
	)
	
	# Die riesigen Klassen-Buttons tauchen auf
	tween.tween_property(classContainer, "modulate:a", 1.0, 0.6)

# --- HOVER LOGIK ---
func _on_class_hover_started(hovered_class: String):
	var data = char_data[hovered_class]
	
	# Stats horizontal aufbauen für besseres Layout
	var stats_text = "[center][color=yellow]HP:[/color] [color=white]" + str(data.hp) + "[/color] | "
	stats_text += "[color=yellow]END:[/color] [color=white]" + str(data.end) + "[/color] | "
	stats_text += "[color=yellow]Str:[/color] [color=white]" + str(data.str) + "[/color] | "
	stats_text += "[color=yellow]Stam:[/color] [color=white]" + str(data.stam) + "[/color] | "
	stats_text += "[color=yellow]Dex:[/color] [color=white]" + str(data.dex) + "[/color] | "
	stats_text += "[color=yellow]Luck:[/color] [color=white]" + str(data.luck) + "[/color] | "
	stats_text += "[color=yellow]Gold:[/color] [color=white]" + str(data.gold) + "[/color] | "
	stats_text += "[color=yellow]Alignment:[/color] [color=white]" + str(data.alignment) + "[/color][/center]\n\n"
	
	stats_text += data.story
	
	classStatsLabel.text = stats_text
	classStatsPanel.visible = true
	classStatsPanel.modulate.a = 0.0 # Sicherstellen, dass es auf 0 startet
	
	var tween = create_tween()
	tween.tween_property(classStatsPanel, "modulate:a", 1.0, 0.2)

func _on_class_hover_ended():
	classStatsPanel.visible = false

# --- ENDE: AB IN DIE STADT ---
func choose_class(chosen_class: String):
	print("Player chose: ", chosen_class)
	GameManager.setup_player(chosen_class)
	
	if GameManager.main_node:
		if GameManager.main_node.has_method("show_ui_bar"):
			GameManager.main_node.show_ui_bar()
		GameManager.main_node.change_scene("res://scenes/city_hub.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
