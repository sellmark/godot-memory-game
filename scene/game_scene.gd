extends Control

# Array to hold the card values and textures
var card_values = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6]  # For a 4x3 game (6 pairs)
var card_textures = [
	preload("res://assets/cards/Clubs_card_01.png"),
	preload("res://assets/cards/Clubs_card_11.png"),
	preload("res://assets/cards/Diamonds_card_01.png"),
	preload("res://assets/cards/Diamonds_card_11.png"),
	preload("res://assets/cards/Hearts_card_01.png"),
	preload("res://assets/cards/Hearts_card_11.png"),
	preload("res://assets/cards/Spades_card_01.png"),
	preload("res://assets/cards/Spades_card_11.png")
]


func _ready():
	shuffle_deck()
	deal_cards()
	
func shuffle_deck():
	card_values.shuffle()  # Randomizes the order of card values

# Function to deal cards
func deal_cards():
	shuffle_deck()

	var index = 0
	for card in $CardGrid.get_children():
		var card_value = card_values[index]
		var texture = card_textures[card_value - 1]  # Associate card value with texture
		card.set_card_value(card_value, texture)  # Set the card's value and texture
		card.connect("flipped", _on_card_flipped)  # Connect the flipped signal
		index += 1

# Callback to handle the card flipping event
func _on_card_flipped(flipped_card):
	# Handle the game logic here (e.g., check for pairs, etc.)
	pass
