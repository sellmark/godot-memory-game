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
var total_score = 0  # Cumulative score for all rounds
var round_score = 0  # Score for the current round (reset at the start of each round)
var flipped_cards = []  # Array to hold flipped cards for pair checking
var timer_duration = 45  # Total game time in seconds (1 minute)
var timer_remaining = timer_duration  # Time left in the game
var round_count = 1  # Keep track of the current round
var max_rounds = 3  # Total number of rounds (1 game + 2 extra rounds)
var game_over = false  # Track if the game is over

func _ready():
	$GameOverScreen.visible = false  # Ukryj GameOverScreen na początku
	#$TryAgainButton.connect("pressed", Callable(self, "_on_try_again_pressed"))
	$ResetButton.visible = false  # Hide the "Try Again" button initiall
	$GameTimer.start(1.0)  # Start the timer to tick every second
	$GameTimer.connect("timeout", Callable(self, "_on_GameTimer_timeout"))
	shuffle_deck()
	deal_cards()
	update_score_label()  # Initialize score label
	update_timer_label()  # Initialize timer label
	update_round_label()  # Initialize round number label

# Shuffle deck function
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

		# Check if the signal is already connected before connecting
		if not card.is_connected("flipped", Callable(self, "_on_card_flipped")):
			card.connect("flipped", Callable(self, "_on_card_flipped"))

		index += 1
# Reset Button clicked handler
func _on_reset_button_pressed():
	  # Ukryj przycisk reset
	$ResetButton.visible = false
	
	# Zresetuj licznik rundy do 1
	round_count = 1
	update_round_label()  # Zaktualizuj wyświetlany numer rundy
	reset_game()

# Function to reset the cards but keep the score and timer
func reset_game():
	if game_over:
		game_over = false
		timer_remaining = timer_duration  # Reset the timer to 60 seconds
		$GameTimer.start(1.0)  # Restart the timer

	flipped_cards.clear()  # Clear any flipped cards
	for card in $CardGrid.get_children():
		card.reset_card()  # Reset all cards (flip back and enable interaction)
	deal_cards()  # Shuffle and deal cards again
	print("Game Reset!")

# Callback to handle the card flipping event
func _on_card_flipped(flipped_card):
	if game_over:
		return

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
		
		# Increment the round score when a match is found
		round_score += 1
		update_score_label()
		
		# Check if all pairs are matched for this round
		if round_score == 6:  # Assuming 6 pairs per round
			round_completed()
	else:
		# If they don't match, flip them back after a short delay
		print("No match.")
		await get_tree().create_timer(1.0).timeout
		flipped_cards[0].flip_back()
		flipped_cards[1].flip_back()

	# Clear the flipped cards array for the next attempt
	flipped_cards.clear()

# Function to update the score label
func update_score_label():
	var score_label = $ScoreLabel  # Reference the ScoreLabel node
	score_label.text = "Score: " + str(total_score)  # Update total score in the label

# Timer functions
func _on_GameTimer_timeout():
	if timer_remaining > 0:
		timer_remaining -= 1  # Decrement the timer by 1 second
		update_timer_label()

		if timer_remaining == 0 and round_score < 6:  # Time's up and player hasn't matched all pairs
			game_over = true
			stop_timer()
			$GameOverScreen.visible = true  # Pokaż ekran Game Over
			print("Game Over! You lost!")
			$ResetButton.visible = true  # Show "Try Again" button when the game is lost
	else:
		stop_timer()

func update_timer_label():
	var timer_label = $TimerLabel  # Reference the TimerLabel node
	timer_label.text = "Time: " + str(timer_remaining) + "s"  # Update the timer label

# Function to handle round completion and start a new round
func round_completed():
	if round_count < max_rounds:  # If there are rounds remaining
		# Award points based on remaining time (2 points per second left)
		var bonus_points = timer_remaining * 2
		total_score += bonus_points
		update_score_label()
		print("Bonus points for round: " + str(bonus_points))

		# Prepare for the next round
		round_count += 1
		update_round_label()  # Update the round number
		reset_for_next_round()
	else:
		# If all rounds are complete, stop the game
		game_over = true
		stop_timer()
		print("Game Over! You won all rounds!")
		$ResetButton.visible = true  # Show "Try Again" button after completing all rounds

# Function to update the round number label
func update_round_label():
	var round_label = $RoundNumLabel  # Reference the RoundNumLabel node
	round_label.text = "Round: " + str(round_count)  # Set the text of the label to display the current round

# Reset for the next round without resetting the score or ending the game
func reset_for_next_round():
	flipped_cards.clear()  # Clear any flipped cards
	for card in $CardGrid.get_children():
		card.reset_card()  # Reset all cards
	deal_cards()  # Shuffle and deal cards again
	
	# Reset the timer and round score
	timer_remaining = timer_duration
	round_score = 0  # Reset the round-specific score
	update_timer_label()
	$GameTimer.start(1.0)  # Restart the timer

# Function to stop the timer when the game is over
func stop_timer():
	$GameTimer.stop()  # Stops the timer
	print("Final Score: " + str(total_score))
