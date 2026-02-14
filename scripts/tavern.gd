extends Control

# --- UI REFERENZEN ---
@onready var background = %Background
# @onready var dayLabel = %DayLabel
@onready var goldLabel = %GoldLabel
@onready var blackOverlay = %BlackOverlay # Das neue schwarze Rechteck

# Buttons (Frei platziert)
@onready var btnBack = %BtnBack
@onready var btnFood = %BtnFood
@onready var btnEvents = %BtnEvents
@onready var btnRumors = %BtnRumors
@onready var btnSleep = %BtnSleep

# --- ASSETS ---
var img_day = preload("res://assets/sprites/tavern-day-bg.jpg")
var img_night = preload("res://assets/sprites/tavern-night-bg.jpg")

func _ready():
	# FADE IN (Vorhang auf)
	# Wir zwingen es sicherheitshalber auf Schwarz (falls im Editor vergessen)
	blackOverlay.modulate.a = 1.0 
	
	var tween = create_tween()
	# In 1.0 Sekunden von Schwarz (1) zu Transparent (0)
	tween.tween_property(blackOverlay, "modulate:a", 0.0, 0.4)
	# UI Setup
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	# dayLabel.text = "Day: " + str(GameManager.current_day)
	
	# Buttons verbinden
	btnBack.pressed.connect(_on_btn_back_pressed)
	btnSleep.pressed.connect(_on_btn_sleep_pressed)
	
	# Start-Check: Ist es Tag oder Nacht?
	update_visuals()

func update_visuals():
	if GameManager.is_night:
		setup_night_mode()
	else:
		setup_day_mode()

func setup_night_mode():
	background.texture = img_night
	
	# Nachts: Schlafen & Gerüchte sichtbar
	btnRumors.visible = true
	btnSleep.visible = true
	
	# Textfarbe anpassen (damit man es auf dunklem Grund liest)
	# if dayLabel: dayLabel.add_theme_color_override("font_color", Color.WHITE)
	if goldLabel: goldLabel.add_theme_color_override("font_color", Color.WHITE)

func setup_day_mode():
	background.texture = img_day
	
	# Tagsüber: Schlafen & Gerüchte weg
	btnRumors.visible = false
	btnSleep.visible = false
	
	# if dayLabel: dayLabel.add_theme_color_override("font_color", Color.BLACK)
	if goldLabel: goldLabel.add_theme_color_override("font_color", Color.BLACK)

# --- ACTIONS ---

func _on_btn_sleep_pressed():
	# 1. Overlay blockiert Maus-Inputs (damit man nicht 2x klickt)
	blackOverlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fade Out (zu Schwarz)
	var tween = create_tween()
	tween.tween_property(blackOverlay, "modulate:a", 1.0, 1.0) # 1 Sekunde Dauer
	
	# Warten bis Animation fertig
	await tween.finished
	
	# --- HIER PASSIERT DER TAGESWECHSEL ---
	GameManager.is_night = false
	GameManager.current_day += 1
	GameManager.playerHp = GameManager.playerMaxHp # Heilung über Nacht!
	
	# UI aktualisieren (während es schwarz ist)
	# dayLabel.text = "Day: " + str(GameManager.current_day)
	update_visuals() # Bild tauschen, Buttons verstecken
	
	# Kurze Pause im Dunkeln (wirkt gemütlicher)
	await get_tree().create_timer(0.5).timeout
	
	# 3. Fade In (wieder transparent)
	var tween_in = create_tween()
	tween_in.tween_property(blackOverlay, "modulate:a", 0.0, 1.0)
	
	await tween_in.finished
	
	# Maus wieder freigeben
	blackOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_btn_back_pressed():
	# 1. Maus blockieren
	if blackOverlay: blackOverlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fade Out (Schwarz werden) - SCHNELLER (0.4s)
	var tween = create_tween()
	if blackOverlay:
		tween.tween_property(blackOverlay, "modulate:a", 1.0, 0.4)
		await tween.finished
	
	# 3. Jetzt wechseln
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
