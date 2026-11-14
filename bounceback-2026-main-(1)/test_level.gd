extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Planet/Borders/CollisionShape2D.disabled = true
	$Planet/Borders/CollisionShape2D2.disabled = true
	$Planet/Borders/CollisionShape2D3.disabled = true
	$Planet/Borders/CollisionShape2D4.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	$Planet/Area2D.visible = false
	$Planet/WaypointMarker.visible = false
	$Planet/Borders/CollisionShape2D.set_deferred("disabled", false)
	$Planet/Borders/CollisionShape2D2.set_deferred("disabled", false)
	$Planet/Borders/CollisionShape2D3.set_deferred("disabled", false)
	$Planet/Borders/CollisionShape2D4.set_deferred("disabled", false)
