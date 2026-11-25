extends CanvasLayer

## Pause overlay. Drop this scene into a level and the "pause" action toggles it.
## Keeps processing while the tree is paused so the menu stays interactive.

@onready var menu: Control = $Menu

var is_paused: bool = false


func _ready() -> void:
	visible = false
	menu.resume_requested.connect(resume)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if is_paused:
		resume()
	else:
		pause()


func pause() -> void:
	is_paused = true
	visible = true
	get_tree().paused = true


func resume() -> void:
	is_paused = false
	visible = false
	get_tree().paused = false
