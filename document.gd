extends Area3D

@onready var mesh: Node3D = $Model


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	mesh.rotate_y(delta)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.add_document()
		queue_free()
