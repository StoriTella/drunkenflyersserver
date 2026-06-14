extends Node

class_name BallTypeEnum

enum BallType {
	NORMAL,
	BOMB,
	BOOMERANG,
	BALAOSAOJOAO,
	ANVIL,
	POLEN,
	TUMBLEWEED,
	RUBBER,
	CANNONBALL
}

@export var ball_type: BallType = BallType.NORMAL
