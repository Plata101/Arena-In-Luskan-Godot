extends Control

# UI Referenzen
@onready var world_container = %WorldContainer
@onready var black_overlay = %BlackOverlay
@onready var gold_label = %GoldLabel
@onready var day_label = %DayLabel
@onready var btn_back = %BtnBack
@onready var btn_inventory = %BtnInventory

# Pfad zur Start-Szene (City Hub)
var start_scene_path = "res://scenes/city_hub.tscn"
# Wir merken uns die instanziierte Szene, um sie löschen zu können
var current_scene_node = null

func _ready():
	# Wir melden uns beim GameManager an
	GameManager.main_node = self
	
	# Overlay initialisieren (sicherstellen, dass es unsichtbar startet)
	if black_overlay:
		black_overlay.visible = true # Muss an sein, damit man es sieht
		black_overlay.modulate.a = 0.0 # Aber komplett durchsichtig
		# Maus-Filter ignorieren, damit man klicken kann
		black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Buttons verbinden
	btn_back.pressed.connect(_on_btn_back_pressed)
	btn_inventory.pressed.connect(_on_btn_inventory_pressed)
	
	# Startszene laden (ohne Fade beim allerersten Start, oder mit - wie du magst)
	# Hier rufen wir direkt die interne Logik auf, damit es sofort da ist
	_switch_scene_content(start_scene_path)
	update_ui()

# --- UI UPDATE ---
func update_ui():
	# Nutzt die Variablen aus dem GameManager
	# Achtung: Stelle sicher, dass im GameManager "currentGold" und "current_day" existieren
	# (snake_case vs CamelCase beachten, wie wir vorhin besprochen haben)
	if gold_label: gold_label.text = "Gold: " + str(GameManager.currentGold)
	if day_label: day_label.text = "Day: " + str(GameManager.current_day) # Oder currentDay

# --- SZENENWECHSEL MIT FADE (Die Haupt-Funktion) ---
func change_scene(scene_path: String):
	print("Starte Fade zu: ", scene_path) # DEBUG: Sehen wir das in der Konsole?
	
	# 1. Input blockieren
	black_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fade nach Schwarz (von 0 auf 1)
	var tween = create_tween()
	tween.tween_property(black_overlay, "modulate:a", 1.0, 0.4).from(0.0)
	
	await tween.finished
	print("Bildschirm ist jetzt schwarz.")
	
	# 3. Szene tauschen (im Dunkeln)
	_switch_scene_content(scene_path)
	update_ui()
	check_buttons_visibility(scene_path)
	
	# Kurze Pause, damit es nicht zu hektisch wirkt (Optional)
	await get_tree().create_timer(0.1).timeout
	
	# 4. Fade zurück (von 1 auf 0)
	var tween_in = create_tween()
	tween_in.tween_property(black_overlay, "modulate:a", 0.0, 0.4).from(1.0)
	
	await tween_in.finished
	
	# 5. Input wieder freigeben
	black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("Fade fertig.")
	

# --- INTERNE FUNKTION ZUM TAUSCHEN (ohne Fade) ---
func _switch_scene_content(scene_path: String):
	# Alte Szene entfernen
	if current_scene_node != null:
		current_scene_node.queue_free()
	
	# Neue Szene instanziieren
	var scene_resource = load(scene_path)
	if scene_resource:
		current_scene_node = scene_resource.instantiate()
		world_container.add_child(current_scene_node)
	else:
		print("ERROR: Szene konnte nicht geladen werden: " + scene_path)

# --- SCHLAFEN / TAGESWECHSEL EFFEKT ---
func play_sleep_effect():
	print("Schlafen...")
	black_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Fade OUT (Dunkel werden)
	var tween = create_tween()
	tween.tween_property(black_overlay, "modulate:a", 1.0, 0.5).from(0.0)
	await tween.finished
	
	# --- JETZT IST ES STOCKFINSTER ---
	
	# 2. Logik: Neuer Tag, es wird hell
	GameManager.current_day += 1
	GameManager.is_night = false
	
	# 3. UI Update (TopBar)
	update_ui()
	
	# 4. WICHTIG: Die aktuelle Szene (Taverne) zwingen, den Hintergrund zu aktualisieren
	# Falls dein Tavernen-Skript eine 'update_ui' oder '_process' Logik hat, greift das hier.
	# Wenn du den Hintergrund in '_ready' setzt, müssen wir die Szene neu laden:
	if current_scene_node:
		# Option A: Wenn die Taverne eine update Funktion hat (Elegant)
		if current_scene_node.has_method("update_ui"):
			current_scene_node.update_ui()
			
		# Option B (Brachial): Einfach die Taverne neu laden, damit '_ready' feuert (Sicherste Methode)
		# _switch_scene_content("res://scenes/tavern.tscn") # Pfad anpassen falls nötig!
	
	# Kurze Pause im Dunkeln (Schlaf simulieren)
	await get_tree().create_timer(0.8).timeout
	
	# --- AUFWACHEN ---
	
	# 5. Fade IN (Hell werden)
	var tween_in = create_tween()
	tween_in.tween_property(black_overlay, "modulate:a", 0.0, 0.5).from(1.0)
	await tween_in.finished
	
	black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
# --- BUTTON LOGIK ---
func check_buttons_visibility(path: String):
	# Back-Button Logik
	if "city_hub" in path:
		btn_back.visible = false
	elif "battle" in path:
		btn_back.visible = false # Button wird vom Battle-Script gesteuert
	else:
		btn_back.visible = true 
		btn_back.text = "Back to City" # Text resetten, falls er vom Battle geändert wurde
		
	# Inventory Button Logik
	if "battle" in path:
		btn_inventory.visible = false
	else:
		btn_inventory.visible = true

# --- BUTTON ACTIONS ---
func _on_btn_back_pressed():
	# Nutzt jetzt auch die Fade-Funktion
	change_scene("res://scenes/city_hub.tscn")

func _on_btn_inventory_pressed():
	print("Open Inventory...")
	# change_scene("res://scenes/inventory_screen.tscn")
