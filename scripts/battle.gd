extends Control

@onready var goldLabel = %GoldLabel
@onready var btnBack = %BtnBack 


func _ready():
	
	# 1. Header Updates (Gold anzeigen)
	if goldLabel:
		goldLabel.text = "Gold: " + str(GameManager.currentGold)
	
	# 2. Back Button verbinden
	# Prüfen ob der Button da ist, um Abstürze zu vermeiden
	if btnBack:
		btnBack.pressed.connect(_on_btn_back_pressed)

func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/city_hub.tscn")
