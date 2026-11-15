extends Area3D

@export var path_node: Node3D
@export var speed := 3.0
@export var turn_speed := 4.0
@export var loop := true
@export var model_offset := 0.0

var points: Array[Vector3] = []
var index := 1

func _ready() -> void:
  body_entered.connect(_on_body_entered)

  if path_node:
    for p in path_node.get_children():
      points.append(p.global_position)
  if points.size() > 0:
    global_position = points[0]
    index = 1 % points.size()

  _play_animation()

func _play_animation() -> void:
  var players := find_children("*", "AnimationPlayer", true, false)
  if players.is_empty():
    return
  var ap: AnimationPlayer = players[0]
  for anim_name in ap.get_animation_list():
    if anim_name == "RESET":
      continue
    ap.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
    ap.play(anim_name)
    return

func _physics_process(delta: float) -> void:
  if points.size() < 2:
    return

  var dir := points[index] - global_position
  if dir.length() < 0.3:
    index += 1
    if index >= points.size():
      if loop:
        index = 0
      else:
        set_physics_process(false)
    return

  dir = dir.normalized()
  global_position += dir * speed * delta

  var angle := atan2(dir.x, dir.z) + model_offset
  rotation.y = lerp_angle(rotation.y, angle, turn_speed * delta)

func _on_body_entered(body: Node3D) -> void:
  if body.has_method("respawn"):
    body.respawn()
