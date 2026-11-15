extends Area3D

@export var required := 4

@onready var visual: Node3D = $Visual

var is_open := false
var finished := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_open(false)
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.documents_changed.connect(_on_documents_changed)


func _on_documents_changed(count: int) -> void:
	if count >= required and not is_open:
		set_open(true)


func set_open(value: bool) -> void:
	is_open = value
	visual.visible = value
	set_deferred("monitoring", value)


func _on_body_entered(body: Node3D) -> void:
	if finished or not is_open or not body.is_in_group("player"):
		return
	finished = true
	body.finish_game()
