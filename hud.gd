extends CanvasLayer

@export var required := 4

@onready var label: Label = $DocLabel


func _ready() -> void:
	update_text(0)
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.documents_changed.connect(update_text)


func update_text(count: int) -> void:
	label.text = "Документы: %d/%d" % [count, required]
