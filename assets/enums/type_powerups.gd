extends Node

class_name PowerTypeEnum

enum PowerType {
	COIN,
	# HEALTH
}

@export var power_type: PowerType = PowerType.COIN

func get_power_type_name() -> String:
	match power_type:
		PowerType.COIN:
			return "Coin"
		_:
			return "Desconhecido"
