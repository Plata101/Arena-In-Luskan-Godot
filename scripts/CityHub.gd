extends Node2D

# Wir holen uns die Referenzen zu den Labels
# Das "%" Zeichen ist ein genialer Trick in Godot 4 (Unique Names).
# Dazu gleich mehr unten!
@onready var goldLabel = %GoldLabel
@onready var dayLabel = %DayLabel

func _ready():
	# Wenn die Szene startet, aktualisieren wir die UI mit den Daten aus dem GameManager
	update_ui()
	
func update_ui():
	# Wir greifen auf den globalen GameManager zu
	goldLabel.text = "Gold: " + str(GameManager.currentGold)
	dayLabel.text = "Day: " + str(GameManager.currentDay)
	
	
# Diese Funktionen erstellen wir gleich über Signale
func _on_btn_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
	
	
func _on_btn_armory_pressed():
	#TODO Logik, Tag hochzählen etc.
	get_tree().change_scene_to_file("res://scenes/armory.tscn")
	
	
func _on_btn_arena_pressed():
	#TODO Logik, Tag hochzählen etc.
	get_tree().change_scene_to_file("res://scenes/arena_prep.tscn")
