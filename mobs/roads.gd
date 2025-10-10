class_name Roads extends TileMapLayer
#get all nodes for use with Road & setup AStar
var astar_2d:= AStar2D.new()
var road_tiles: Array[Vector2i]  
var map_size: Vector2i  

func _ready() -> void:
	road_tiles = get_used_cells()  
	map_size = get_used_rect().size  
	_prepare_pathfinding_graph()


func _prepare_pathfinding_graph() -> void:
	for current_cell: Vector2i in road_tiles:
		var current_cell_index := calculate_index(current_cell)
		astar_2d.add_point(current_cell_index, current_cell)

	for current_cell: Vector2i in road_tiles:
		for current_neighbor: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
			var neighbor_position := current_cell + current_neighbor
			if get_cell_source_id(neighbor_position) == -1:
				continue
				
			var current_cell_index := calculate_index(current_cell)
			var next_index := calculate_index(neighbor_position)
			# We need to check for existing connections because for each cell we check all 4 neighbor coordinates
			if not astar_2d.are_points_connected(current_cell_index, next_index):
				astar_2d.connect_points(current_cell_index, next_index)
		
	#Get Unique ID for each square in he grid
func calculate_index(cell_coordinates: Vector2i) -> int:
	return cell_coordinates.x + (cell_coordinates.y * map_size.x) + 10_000

func find_path_to_target(mob_spawner_node: Node2D, target_node: Node2D) -> PackedVector2Array:
	var target_position := local_to_map(target_node.global_position)
	var start_position := local_to_map(mob_spawner_node.global_position)

	var start_index := calculate_index(start_position)
	var end_index := calculate_index(target_position)

	var cell_coordinates := astar_2d.get_point_path(start_index, end_index)


	var world_coordinates := PackedVector2Array()
	for current_cell in cell_coordinates:
		world_coordinates.append(map_to_local(current_cell))

	return world_coordinates
