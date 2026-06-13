extends Node

class_name PointsTypeEnum

enum PointsType {
	COIN,
	GOLD,
	GOLD_SNAKE,
	GOLD_SPAWNER,
	DIAMOND,
}

@export var points_type: PointsType = PointsType.COIN
