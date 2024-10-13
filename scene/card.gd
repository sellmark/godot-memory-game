extends Control

# Signals
signal flipped(card)

# Variables
var value = 0  # The value associated with the card, e.g., 1, 2, 3, etc.
var is_flipped = false
var is_matched = false  # To track if the card has been matched and should remain flipped
var front_texture = null  # The front texture (depends on the card's value)
var back_texture = preload("res://assets/cards/back_0.png")  # Shared back texture for all cards
var texture_button = null  # To store the TextureButton reference

# Function to handle the click (triggered by the TextureButton)
func _ready():
	# Reference the TextureButton node only once to avoid multiple lookups
	texture_button = $CardTexture  
	texture_button.texture_normal = back_texture  # Set the back texture initially
	texture_button.connect("pressed", _on_TextureButton_pressed)  # Connect pressed signal

# Function called when the TextureButton is pressed
func _on_TextureButton_pressed():
	if not is_flipped and not is_matched:  # Prevent flipping if already flipped or matched
		flip_card()

# Function to flip the card
func flip_card():
	# Only proceed if front_texture is set to prevent flipping before initialization
	if front_texture == null:
		print("Front texture not set, cannot flip the card.")
		return

	is_flipped = !is_flipped
	update_card_appearance()

	# Emit a signal to notify the game that this card has been flipped
	emit_signal("flipped", self)

# Function to update the card's texture based on its flipped state
func update_card_appearance():
	if is_flipped or is_matched:
		texture_button.texture_normal = front_texture  # Show the front of the card
	else:
		texture_button.texture_normal = back_texture  # Show the back of the card

# Function to set the value and texture of the card
func set_card_value(new_value, texture):
	value = new_value
	front_texture = texture  # Bind the texture to the value
	update_card_appearance()  # Ensure the correct texture is shown if the card was flipped

# Optional function to manually flip back the card (useful for mismatched pairs)
func flip_back():
	if is_flipped and not is_matched:  # Only flip if the card is already flipped and not matched
		is_flipped = false
		update_card_appearance()

# Function to disable the card when a match is found
func disable_card():
	is_matched = true  # Mark the card as matched so it stays revealed and unclickable
	update_card_appearance()
	set_process_input(false)  # Disable user interaction with the card

# Reset the card to enable interaction again (used when resetting the game)
func reset_card():
	is_flipped = false
	is_matched = false  # Reset matched status
	update_card_appearance()
	set_process_input(true)  # Re-enable interaction

# Method to check if the card is revealed
func is_revealed() -> bool:
	return is_flipped or is_matched  # Return true if the card is flipped or matched
