extends Node3D

@export var leg_angle := 30.0
@export var arm_angle := 25.0
@export var step_speed := 0.3

var skeleton: Skeleton3D
var rest := {}
var t := 0.0
var amount := 0.0
var bone_names := ["LeftUpperLeg", "RightUpperLeg", "LeftUpperArm", "RightUpperArm"]


func _ready() -> void:
	var found := find_children("*", "Skeleton3D", true, false)
	if found.size() == 0:
		return
	skeleton = found[0]
	for n in bone_names:
		var i := skeleton.find_bone(n)
		if i != -1:
			rest[n] = skeleton.get_bone_pose_rotation(i)


func _process(delta: float) -> void:
	if skeleton == null:
		return
	var body := get_parent()
	var spd := Vector2(body.velocity.x, body.velocity.z).length()
	var moving: bool = spd > 0.1 and body.is_on_floor()

	amount = move_toward(amount, 1.0 if moving else 0.0, 6.0 * delta)
	if moving:
		t += delta * spd * step_speed

	var s := sin(t * TAU) * amount
	swing("LeftUpperLeg", s * leg_angle)
	swing("RightUpperLeg", -s * leg_angle)
	swing("LeftUpperArm", -s * arm_angle)
	swing("RightUpperArm", s * arm_angle)


func swing(bone: String, degrees: float) -> void:
	var i := skeleton.find_bone(bone)
	if i == -1 or not rest.has(bone):
		return
	var q := Quaternion(Vector3.RIGHT, deg_to_rad(degrees))
	skeleton.set_bone_pose_rotation(i, rest[bone] * q)
