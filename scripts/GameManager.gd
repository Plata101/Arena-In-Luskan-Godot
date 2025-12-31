extends Node

# Spieler-Daten
var currentGold: int = 100
var playerHp: int = 100
var playerMaxHp: int = 100
var playerStrength: int = 5
var playerArmor: int = 0

# Spiel-Status
var currentDay: int = 1
var maxDays: int = 100

# Inventory

var inventory: Array = []

var currentEnemy = {} # Hier speichern wir das ausgewählte Monster vor dem Szenenwechsel
