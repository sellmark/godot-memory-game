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

# Variables
var score = 0  # Variable to hold the player's score
var flipped_cards = []  # Array to hold currently flipped cards for pair checking

func _ready():
	shuffle_deck()
	deal_cards()
	update_score_label()  # Initialize score label

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
	# Add the flipped card to the list of flipped cards
	flipped_cards.append(flipped_card)
	
	# If two cards are flipped, check if they match
	if flipped_cards.size() == 2:
		check_for_pair()

# Function to check if two flipped cards are a pair
func check_for_pair() -> void:
	if flipped_cards[0].value == flipped_cards[1].value:
		# If they match, keep them revealed and disable further interaction
		print("Match found!")
		flipped_cards[0].disable_card()
		flipped_cards[1].disable_card()
		
		# Increment the score when a match is found
		score += 1
		update_score_label()
	else:
		# If they don't match, flip them back after a short delay
		print("No match.")
		await get_tree().create_timer(1.0).timeout  # Use await instead of yield
		flipped_cards[0].flip_back()
		flipped_cards[1].flip_back()

	# Clear the flipped cards array for the next attempt
	flipped_cards.clear()

# Function to update the score label
func update_score_label():
	var score_label = $ScoreLabel  # Reference the ScoreLabel node
	score_label.text = "Score: " + str(score)  # Set the text of the label
