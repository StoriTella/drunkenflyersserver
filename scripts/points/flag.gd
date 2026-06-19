extends RigidBody2D
class_name AttachableGold

@export var coin_type: PointsTypeEnum.PointsType = PointsTypeEnum.PointsType.FLAG
@export var points_per_tick: float = 0.1
@export var expiration_date: float = 30.0
@export var follow_offset: Vector2 = Vector2(0, -20)

#Generic
@export var point_delay: float = 15.0
@export var rotation_angle: float = 2.5

var player_owner: Node2D = null
var is_active: bool = false

func _ready():
	await get_tree().create_timer(expiration_date).timeout
	queue_free()

func initialize(start_pos: Vector2):
	position = start_pos

func _process(delta):
	process_flag(delta)
	if player_owner:
		global_position = player_owner.global_position + follow_offset

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not player_owner:
		player_owner = body
		is_active = true
		Global.rpc_id(body.player_id, "flag_collect_sound")
	elif body != player_owner:
		player_owner = body
		is_active = true
		Global.rpc_id(body.player_id, "flag_steal_sound")

func process_flag(delta):
	if player_owner and is_active:
		rotation += rotation_angle * delta
		Global.players.get(player_owner.player_id).points += points_per_tick
		print(Global.players.get(player_owner.player_id).points)
