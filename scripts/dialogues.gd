extends Node

# --- THORFIN ---
var thorfin = {
	"start": {
		"text": "Well met, stranger. What brings you to this gloomy place?",
		"choices": [
			{"text": "Well met too, what news on the riddermark?", "next_node": "news"},
			{"text": "Howdy, I see you already had 5 glasses of beer.", "next_node": "drunk"},
			{"text": "Just passing through. (Leave)", "next_node": "end"}
		]
	},
	"news": {
		"text": "The orks are gathering in the mountains. Dark times are ahead of us.",
		"choices": [
			{"text": "I will slay them all! (Good Alignment)", "next_node": "end"},
			{"text": "Not my problem. (Leave)", "next_node": "end"}
		]
	},
	"drunk": {
		"text": "Mind your own business, you scoundrel! *hiccup*",
		"choices": [
			{"text": "Sorry, my bad. (Leave)", "next_node": "end"}
		]
	}
}

# --- BARKEEPER ---
# --- BARKEEPER ---
var inkeeper = {
	"start": {
		# --- NEU: Der Text passt sich jetzt dynamisch an! ---
		"text": func():
			if GameManager.beers_drank_today >= 2:
				return "It looks like you had enough for today, friend. Come back tomorrow."
			elif GameManager.beers_drank_today > 0:
				return "Oh you're thirsty, another round for you? (5 Gold)"
			else:
				return "Welcome to the Dragon's Tankard! Best ale in all of Luskan. (5 Gold)",
				
		"choices": [
			{
		"text": "A pint of your finest ale, please.", 
		"next_node": "ale",
		# BEDINGUNG: Zeigen, wenn Gold reicht UND wir UNTER 3 Bieren sind
		"condition": func(): return GameManager.currentGold >= 5 and GameManager.beers_drank_today < 2,
		"effect": func(): 
			GameManager.currentGold -= 5
			GameManager.playerHp += 10
			GameManager.beers_drank_today += 1
			GameManager.daily_events.append({
						"text": "While you were drinking, a thief stole 10 Gold from your pocket!",
						"effect": func(): GameManager.currentGold -= 10
					})
			GameManager.daily_events.append({
						"text": "Rumors say the King brought a new monster to the arena...",
						# Hier könntest du später einen Boss freischalten!
					})
			if GameManager.playerHp > GameManager.playerMaxHp:
				GameManager.playerHp = GameManager.playerMaxHp
			if GameManager.main_node and GameManager.main_node.has_method("update_ui"):
				GameManager.main_node.update_ui()
			},
			{
				"text": "I can't afford that... (Leave)",
				"next_node": "end",
				# BEDINGUNG: Nur zeigen, wenn Gold NICHT reicht UND wir UNTER 3 Bieren sind
				"condition": func(): return GameManager.currentGold < 5 and GameManager.beers_drank_today < 2
			},
			{
				# --- NEU: Der Button, wenn man rausgeworfen wird ---
				"text": "Fine... *hiccup* (Leave)",
				"next_node": "end",
				"condition": func(): return GameManager.beers_drank_today >= 2
			},
			{
				# --- NEU: Der Button, wenn man rausgeworfen wird ---
				"text": "Your ale tastes like orc piss anyways (Leave)",
				"next_node": "end",
				"condition": func(): return GameManager.beers_drank_today >= 2
			},
			{
				"text": "Just looking around. (Leave)", 
				"next_node": "end",
				# Optional: Den normalen "Tschüss"-Button verstecken, wenn man betrunken ist
				"condition": func(): return GameManager.beers_drank_today < 2
			},
			
		]
	},
	"ale": {
		"text": func():
			if GameManager.beers_drank_today > 1:
				return "Enjoy my friend, it's brown ale like from another realm! (+10 HP)"
			else:
				return "Here you go! Drink up, it puts hair on your chest. (+10 HP)",
		"choices": [
			{"text": "Thanks! (Leave)", "next_node": "end"}
		]
	}
}
