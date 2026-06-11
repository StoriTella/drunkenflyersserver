extends Node

class_name BallTypeEnum

enum BallType {
	NORMAL,
	FAST,
	# Podes adicionar mais tipos depois:
	# SLOW,
	# BOMB,
	# HEALTH
}

@export var ball_type: BallType = BallType.NORMAL

func get_ball_type_name() -> String:
	match ball_type:
		BallType.NORMAL:
			return "Normal"
		BallType.FAST:
			return "Rápida"
		_:
			return "Desconhecido"
