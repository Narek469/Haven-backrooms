extends CharacterBody3D

signal sanity_changed(current: float, maximum: float)
signal documents_changed(count: int)

@export var speed := 5.0
@export var accel := 14.0
@export var friction := 16.0
@export var turn_speed := 12.0
@export var jump_velocity := 4.5
@export var max_sanity := 100.0
@export var mouse_sens := 0.003
@export var third_person_distance := 3.5
@export var model_offset := PI

@export var model: Node3D
@export var head: Node3D
@export var spring_arm: SpringArm3D

var sanity := 100.0
var documents := 0
var dead := false
var third_person := false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	add_to_group("player")
	sanity = max_sanity
	sanity_changed.emit(sanity, max_sanity)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spring_arm.add_excluded_object(get_rid())
	model.rotation.y = model_offset
	set_view(false, false)


func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sens)
		head.rotation.x = clampf(head.rotation.x - event.relative.y * mouse_sens, -1.4, 1.4)

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			set_view(true)
		elif event.keycode == KEY_O:
			set_view(false)
		elif event.keycode == KEY_R:
			respawn()
		elif event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func set_view(to_third: bool, smooth := true) -> void:
	third_person = to_third
	var length := third_person_distance if to_third else 0.0

	if smooth:
		create_tween().tween_property(spring_arm, "spring_length", length, 0.25)
	else:
		spring_arm.spring_length = length

	if model:
		model.visible = to_third


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var local_dir := Vector3(input_dir.x, 0, input_dir.y)
	var dir := (transform.basis * local_dir).normalized()

	var rate := accel if dir != Vector3.ZERO else friction
	velocity.x = move_toward(velocity.x, dir.x * speed, rate * delta)
	velocity.z = move_toward(velocity.z, dir.z * speed, rate * delta)
	move_and_slide()

	if local_dir != Vector3.ZERO and model:
		var angle := atan2(-local_dir.x, -local_dir.z) + model_offset
		model.rotation.y = lerp_angle(model.rotation.y, angle, turn_speed * delta)


func add_document() -> void:
	documents += 1
	documents_changed.emit(documents)


func lose_all_sanity() -> void:
	if dead:
		return
	dead = true
	sanity = 0.0
	sanity_changed.emit(sanity, max_sanity)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()


func respawn() -> void:
	var spawn := get_tree().get_first_node_in_group("spawn")
	if spawn:
		global_position = spawn.global_position
	velocity = Vector3.ZERO
	sanity = max_sanity
	sanity_changed.emit(sanity, max_sanity)

func finish_game() -> void:
	dead = true
	velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var layer := CanvasLayer.new()
	var label := Label.new()
	label.text = "Игра окончена"
	label.add_theme_font_size_override("font_size", 64)
	label.set_anchors_preset(Control.PRESET_CENTER)
	layer.add_child(label)
	get_tree().root.add_child(layer)
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()
