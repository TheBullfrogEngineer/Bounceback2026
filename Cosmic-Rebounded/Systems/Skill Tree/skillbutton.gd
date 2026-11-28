extends TextureButton
class_name SkillNode

@onready var panel: Panel = $Panel
@onready var label: Label = $MarginContainer/Label
@onready var line_2d: Line2D = $Line2D
@onready var description: NinePatchRect = $NinePatchRect


func _ready():
	description.visible = false
	if get_parent() is SkillNode:
		line_2d.add_point(global_position + size/2)
		line_2d.add_point(get_parent().global_position + size/2)

var level : int = 0:
	set(value):
		level = value
		label.text = str(level) + "/3"

func _on_pressed() -> void:
	level = min(level+1, 3)
	panel.size.y -= (40/3)
	panel.position.y += (40/3)
	
	line_2d.default_color = Color(0.0, 0.759, 0.226, 1.0)
	
	var skills = get_children()
	for skill in skills:
		if skill is SkillNode and level == 3:
			skill.disabled = false


func _on_mouse_entered() -> void:
	description.visible = true


func _on_mouse_exited() -> void:
	description.visible = false
