extends Node

enum SpawnSide {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

func get_random_position_in_screen(margin: float = 50.0) -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var left = -viewport_size.x / 2 + margin
	var right = viewport_size.x / 2 - margin
	var top = -viewport_size.y / 2 + margin
	var bottom = viewport_size.y / 2 - margin
	
	var random_x = randf_range(left, right)
	var random_y = randf_range(top, bottom)
	
	return Vector2(random_x, random_y)

func get_random_position_outside_screen(margin: float = 50.0) -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var left = -viewport_size.x / 2 - margin
	var right = viewport_size.x / 2 + margin
	var top = -viewport_size.y / 2 - margin
	var bottom = viewport_size.y / 2 + margin
	
	var spawn_side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match spawn_side:
		SpawnSide.TOP:
			spawn_pos = Vector2(randf_range(left, right), top)
		SpawnSide.BOTTOM:
			spawn_pos = Vector2(randf_range(left, right), bottom)
		SpawnSide.LEFT:
			spawn_pos = Vector2(left, randf_range(top, bottom))
		SpawnSide.RIGHT:
			spawn_pos = Vector2(right, randf_range(top, bottom))
	
	return spawn_pos

func get_random_position_outside_screen_with_target(margin: float = 50.0) -> Dictionary:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var left = -viewport_size.x / 2 - margin
	var right = viewport_size.x / 2 + margin
	var top = -viewport_size.y / 2 - margin
	var bottom = viewport_size.y / 2 + margin
	
	var spawn_side = randi() % 4
	var spawn_pos = Vector2.ZERO
	var target_pos = Vector2.ZERO
	
	match spawn_side:
		SpawnSide.TOP:
			spawn_pos = Vector2(randf_range(left, right), top)
			target_pos = Vector2(randf_range(left, right), -top)
		SpawnSide.BOTTOM:
			spawn_pos = Vector2(randf_range(left, right), bottom)
			target_pos = Vector2(randf_range(left, right), -bottom)
		SpawnSide.LEFT:
			spawn_pos = Vector2(left, randf_range(top, bottom))
			target_pos = Vector2(-left, randf_range(top, bottom))
		SpawnSide.RIGHT:
			spawn_pos = Vector2(right, randf_range(top, bottom))
			target_pos = Vector2(-right, randf_range(top, bottom))
	
	return {
		"spawn": spawn_pos,
		"target": target_pos
	}

func get_position_above_screen(margin: float = 50.0) -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var left = -viewport_size.x / 2 + margin
	var right = viewport_size.x / 2 - margin
	var top = -viewport_size.y / 2 - margin
	
	var random_x = randf_range(left, right)
	return Vector2(random_x, top)

func get_position_below_screen(margin: float = 50.0) -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var left = -viewport_size.x / 2 + margin
	var right = viewport_size.x / 2 - margin
	var bottom = viewport_size.y / 2 + margin
	
	var random_x = randf_range(left, right)
	return Vector2(random_x, bottom)

func get_position_side_to_side(margin: float = 50.0) -> Dictionary:
	var viewport_size = get_viewport().get_visible_rect().size
	var top = -viewport_size.y / 2 + margin
	var bottom = viewport_size.y / 2 - margin
	
	var start_side = randi() % 2
	var spawn_pos = Vector2.ZERO
	var target_pos = Vector2.ZERO
	var random_y = randf_range(top, bottom)
	
	if start_side == 0:
		spawn_pos = Vector2(-viewport_size.x / 2 - margin, random_y)
		target_pos = Vector2(viewport_size.x / 2 + margin, random_y)
	else:
		spawn_pos = Vector2(viewport_size.x / 2 + margin, random_y)
		target_pos = Vector2(-viewport_size.x / 2 - margin, random_y)
	
	return {
		"spawn": spawn_pos,
		"target": target_pos
	}
