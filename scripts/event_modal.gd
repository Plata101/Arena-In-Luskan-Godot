extends CanvasLayer

@onready var counterLabel = %CounterLabel
@onready var eventText = %EventText
@onready var btnNext = %BtnNext

var current_events: Array[Dictionary] = []
var current_index: int = 0

func _ready():
	for child in get_children():
		if child is CanvasItem:
			child.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(child, "modulate:a", 1.0, 0.3)
	if btnNext:
		btnNext.pressed.connect(_on_next_pressed)

# Wird von außen (z.B. der Taverne) aufgerufen, um das Modal zu starten
func setup(events_to_show: Array[Dictionary]):
	current_events = events_to_show
	current_index = 0
	show_current_event()

func show_current_event():
	# Wenn wir alle Events durch haben, schließen wir das Modal
	if current_index >= current_events.size():
		close_modal()
		return
		
	var ev = current_events[current_index]
	
	# 1. Text und Zähler aktualisieren
	eventText.text = "[color=yellow][i]" + ev["text"] + "[/i][/color]"
	counterLabel.text = str(current_index + 1) + " / " + str(current_events.size())
	
	# 2. Button-Text anpassen (beim letzten Event steht "Close" statt "Next")
	if current_index == current_events.size() - 1:
		btnNext.text = "Close"
	else:
		btnNext.text = "Next"
		
	# 3. EFFEKT AUSFÜHREN! (Gibt Gold, zieht HP ab, etc.)
	if ev.has("effect"):
		var effect_func = ev["effect"]
		effect_func.call()
		
		# Optional: UI sofort updaten, damit man z.B. den Gold-Verlust live sieht
		if GameManager.main_node and GameManager.main_node.has_method("update_ui"):
			GameManager.main_node.update_ui()

func _on_next_pressed():
	current_index += 1
	show_current_event()

func close_modal():
	# Liste im GameManager leeren
	GameManager.daily_events.clear()
	
	# --- NEU: FADE OUT EFFEKT ---
	var tween = create_tween()
	
	for child in get_children():
		if child is CanvasItem:
			# parallel() sorgt dafür, dass alle Elemente gleichzeitig ausfaden
			tween.parallel().tween_property(child, "modulate:a", 0.0, 0.2) 
			
	# Wenn die Animation fertig ist, löschen wir das Fenster
	tween.tween_callback(queue_free)
