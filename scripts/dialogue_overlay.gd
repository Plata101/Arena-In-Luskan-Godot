extends CanvasLayer

# --- REFERENZEN ---
@onready var npcPortrait = %NpcPortrait
@onready var npcName = %NpcName
@onready var npcProfession = %NpcProfession
@onready var dialogueText = %DialogueText
@onready var choicesContainer = %ChoicesContainer
@onready var btnClose = %BtnClose

# Leeres Dictionary, wird später von der Taverne gefüllt!
var current_dialogue = {}

func _ready():
	# --- FADE IN EFFEKT ---
	# Wir machen das gesamte Overlay unsichtbar (Alpha = 0)
	# Wichtig: Falls du CanvasLayer nutzt, greifen wir auf das erste Kind zu (den BackgroundDarkener oder ModalBox)
	# Noch einfacher: Wir ändern einfach den modulate-Wert des CanvasLayers (wenn Godot Version das zulässt)
	# Alternativ (sicherer): Packe BackgroundDarkener + ModalBox in einen Control-Node (%MainRoot) 
	# oder wir faden die Nodes einzeln:
	
	# Damit wir alle Kinder faden können, machen wir es so:
	for child in get_children():
		if child is CanvasItem:
			child.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(child, "modulate:a", 1.0, 0.3) # 0.3 Sekunden Fade-In

	# Close Button
	if btnClose:
		btnClose.pressed.connect(close_dialogue)

# --- NEU: Das System, um den Dialog von außen zu füttern ---
func setup_dialogue(npc_name_text: String, npc_prof_text: String, npc_image_path: String, dialogue_dict: Dictionary):
	npcName.text = npc_name_text
	npcProfession.text = npc_prof_text
	
	if ResourceLoader.exists(npc_image_path):
		npcPortrait.texture = load(npc_image_path)
		
	current_dialogue = dialogue_dict
	
	# Starte das Gespräch beim Knoten "start"
	load_dialogue_node("start")

func load_dialogue_node(node_id: String):
	if node_id == "end":
		close_dialogue()
		return
		
	if not current_dialogue.has(node_id):
		return
		
	var node_data = current_dialogue[node_id]
	var raw_text = node_data["text"]
	if raw_text is Callable:
		# Wenn es eine Funktion ist, rufen wir sie auf, um den Text zu bekommen!
		dialogueText.text = "[color=yellow][i]" + raw_text.call() + "[/i][/color]"
		start_typewriter()
		
	else:
		# Wenn es ein normaler Text (String) ist, zeigen wir ihn einfach an
		dialogueText.text = "[color=yellow][i]" + str(raw_text) + "[/i][/color]"
		start_typewriter()
	
	for child in choicesContainer.get_children():
		child.queue_free()
		
	for choice in node_data["choices"]:
		if choice.has("condition"):
			var cond_func = choice["condition"]
			if cond_func.call() == false:
				continue # Überspringt das Erstellen des Buttons
		var btn = Button.new()
		btn.text = choice["text"]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		choicesContainer.add_child(btn)
		
func start_typewriter():
	# 1. Text beim Start komplett unsichtbar machen (0% sichtbar)
	dialogueText.visible_ratio = 0.0
	
	# 2. Dauer dynamisch berechnen! 
	# get_parsed_text() ignoriert [color] und [i] Tags beim Zählen!
	var visible_characters = dialogueText.get_parsed_text().length()
	var type_duration = visible_characters * 0.02 
	
	# 3. Den Tween erstellen und den Text sanft einblenden
	var tween = create_tween()
	tween.tween_property(dialogueText, "visible_ratio", 1.0, type_duration)

func _on_choice_pressed(choice_data: Dictionary):
	# --- NEU: EFFEKT AUSFÜHREN ---
	if choice_data.has("effect"):
		var effect_func = choice_data["effect"]
		effect_func.call() # Führt den Code aus, der in "effect" steht!
		
	# Lade den nächsten Knoten
	load_dialogue_node(choice_data["next_node"])

func close_dialogue():
	# --- FADE OUT EFFEKT ---
	var tween = create_tween()
	# Wir animieren alle Kinder wieder auf Alpha 0
	for child in get_children():
		if child is CanvasItem:
			tween.parallel().tween_property(child, "modulate:a", 0.0, 0.2) # 0.2 Sekunden ausblenden
	
	# Wenn die Animation fertig ist, löschen wir das Fenster
	tween.tween_callback(queue_free)
