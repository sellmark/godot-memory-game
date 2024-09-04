extends Control

# Signals
signal flipped(card)

# Variables
var value = 0  # The value associated with the card, e.g., 1, 2, 3, etc.
var is_flipped = false
var front_texture = null  # The front texture (depends on the card's value)
var back_texture = preload("res://assets/cards/back_0.png")  # Shared back texture for all cards

# Function to handle the click (triggered by the TextureButton)
func _ready():
	var texture_button = $CardTexture  # Reference the TextureButton node
	texture_button.texture_normal = back_texture  # Set the back texture initially
	texture_button.connect("pressed", _on_TextureButton_pressed)  # Connect pressed signal

# Function called when the TextureButton is pressed
func _on_TextureButton_pressed():
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
	var texture_button = $CardTexture  # Reference the TextureButton node again

	if is_flipped:
		texture_button.texture_normal = front_texture  # Show the front of the card
	else:
		texture_button.texture_normal = back_texture  # Show the back of the card

# Function to set the value and texture of the card
func set_card_value(new_value, texture):
	value = new_value
	front_texture = texture  # Bind the texture to the value
	update_card_appearance()  # Ensure the correct texture is shown if the card was flipped
