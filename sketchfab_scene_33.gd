extends Node3D

func _ready() -> void:
	$AnimationPlayer.get_animation("Animation").loop_mode = Animation.LOOP_LINEAR
	$AnimationPlayer.play("Animation")
