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
var timer_duration = 60  # Total game time in seconds
var timer_remaining = timer_duration  # Time left in the game
var round_count = 1  # Keep track of the current round
var max_rounds = 3  # Total number of rounds (1 game + 2 extra rounds)
var game_over = false  # Track if the game is over

func _ready():
	$GameStartScreen.visible = true  # Show StartGameScreen when the game starts
	$GameOverScreen.visible = false  # Hide GameOverScreen at the start
	$ResetButton.visible = false  # Hide ResetButton at the start
	$GameOverScreen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$GameOverScreen/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$GameStartScreen/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Connect signals for button interactions
	$GameStartScreen/StartGameButton.connect("pressed", Callable(self, "_on_start_game_button_pressed"))
	$GameOverScreen/TryAgainButton.connect("pressed", Callable(self, "_on_try_again_button_pressed"))
	$ResetButton.connect("pressed", Callable(self, "_on_reset_button_pressed"))  
	$GameTimer.connect("timeout", Callable(self, "_on_GameTimer_timeout"))  # Connect the timer's timeout signal
func _on_start_game_button_pressed():
	$GameStartScreen.visible = false
	timer_duration = get_round_timer_duration(round_count)
	timer_remaining = timer_duration
	$GameTimer.start(1.0)
	shuffle_deck()
	deal_cards()
	update_score_label()
	update_timer_label()
	update_round_label()

func shuffle_deck():
	card_values.shuffle()  # Randomizes the order of card values

func deal_cards():
	shuffle_deck()
	var index = 0
	for card in $CardGrid.get_children():
		var card_value = card_values[index]
		var texture = card_textures[card_value - 1]  # Associate card value with texture
		card.set_card_value(card_value, texture)  # Set the card's value and texture

		if not card.is_connected("flipped", Callable(self, "_on_card_flipped")):
			card.connect("flipped", Callable(self, "_on_card_flipped"))

		index += 1


# Function to disable all cards
func disable_all_cards():
	for card in $CardGrid.get_children():
		card.texture_button.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Disable user interaction

# Function to enable all cards after checking for a match or mismatch
func enable_all_cards():
	for card in $CardGrid.get_children():
		if not card.is_revealed():  # Only enable cards that are not revealed
			card.texture_button.mouse_filter = Control.MOUSE_FILTER_PASS  # Re-enable interaction


func _on_card_flipped(flipped_card):
	if game_over or flipped_cards.size() >= 2:
		return  # Prevent further interaction if the game is over or if two cards are already flipped

	flipped_cards.append(flipped_card)

	if flipped_cards.size() == 2:
		disable_all_cards()
		check_for_pair()

func check_for_pair() -> void:
	# Assuming that value is accessible on the card
	var first_card_value = flipped_cards[0].value
	var second_card_value = flipped_cards[1].value
	print("Flipped cards values:", first_card_value, second_card_value)  # Debugging output

	if first_card_value == second_card_value:
		print("Match found!")
		flipped_cards[0].disable_card()
		flipped_cards[1].disable_card()
		round_score += 1
		update_score_label()

		await get_tree().create_timer(0.5).timeout  # Delay for visual feedback
		enable_all_cards()

		if round_score == 6:  # Assuming 6 pairs per round
			round_completed()
	else:
		print("No match.")
		await get_tree().create_timer(1.0).timeout  # Delay for visual feedback
		flipped_cards[0].flip_back()
		flipped_cards[1].flip_back()
		enable_all_cards()

	flipped_cards.clear()

func get_round_timer_duration(round: int) -> int:
	match round:
		1: return 60
		2: return 50
		3: return 40
		_: return 30

func _on_reset_button_pressed():
	print("ResetButton pressed!")
	$ResetButton.visible = false
	round_count = 1
	update_round_label()
	total_score = 0
	round_score = 0
	update_score_label()
	timer_duration = get_round_timer_duration(round_count)
	timer_remaining = timer_duration
	reset_game()

func reset_game():
	if game_over:
		game_over = false
		timer_remaining = timer_duration
		update_timer_label()
		$GameTimer.start(1.0)

	flipped_cards.clear()
	for card in $CardGrid.get_children():
		card.reset_card()
	deal_cards()
	print("Game Reset!")

func _on_GameTimer_timeout():
	print("Timer tick! Remaining time:", timer_remaining)
	if timer_remaining > 0:
		timer_remaining -= 1
		update_timer_label()

		if timer_remaining == 0 and round_score < 6:
			game_over = true
			stop_timer()
			$GameOverScreen.visible = true
			$GameOverScreen/TryAgainButton.visible = true
	else:
		stop_timer()

func update_score_label():
	$ScoreLabel.text = "Score: " + str(total_score)

func update_timer_label():
	$TimerLabel.text = "Time: " + str(timer_remaining) + "s"

func stop_timer():
	$GameTimer.stop()
	print("Final Score: " + str(total_score))

func round_completed():
	if round_count < max_rounds:
		var bonus_points = timer_remaining * 2
		total_score += bonus_points
		update_score_label()
		print("Bonus points for round: " + str(bonus_points))
		round_count += 1
		update_round_label()
		reset_for_next_round()
	else:
		var bonus_points = timer_remaining * 2
		total_score += bonus_points
		update_score_label()
		game_over = true
		stop_timer()
		print("Game Over! You won all rounds!")
		$ResetButton.visible = true

func reset_for_next_round():
	flipped_cards.clear()
	for card in $CardGrid.get_children():
		card.reset_card()  # Reset each card to its initial state
		card.texture_button.mouse_filter = Control.MOUSE_FILTER_PASS  # Ensure interaction is enabled
	deal_cards()  # Deal new cards for the next round
	timer_duration = get_round_timer_duration(round_count)  # Set timer for next round
	timer_remaining = timer_duration  # Reset remaining time
	round_score = 0  # Reset round score
	update_timer_label()  # Update timer label to reflect changes
	$GameTimer.start(1.0)  # Restart the game timer


func update_round_label():
	$RoundNumLabel.text = "Round: " + str(round_count)

func _on_try_again_button_pressed():
	round_count = 1
	update_round_label()
	$GameOverScreen.visible = false
	$GameOverScreen/TryAgainButton.visible = false
	total_score = 0
	round_score = 0
	update_score_label()
	timer_duration = get_round_timer_duration(round_count)
	timer_remaining = timer_duration
	reset_game()
