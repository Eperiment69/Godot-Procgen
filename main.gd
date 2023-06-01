extends Node2D

var Room = preload("res://Scenes/room.tscn")

var cull = 0.7
var tile_size = 16  # size of a tile in the TileMap
var num_rooms = 50  # number of rooms to generate
var min_size = 15 # minimum room size (in tiles)
var max_size = 25  # maximum room size (in tiles)
var hspread = 400
var path
var room_positions = []
var triangles
var rooms_connected = false


func _ready():
	randomize()
	make_rooms()
	
func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(randf_range(-hspread, hspread), randf_range(-hspread, hspread))
		var r = Room.instantiate()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	await get_tree().create_timer(0.5).timeout
	cull_rooms()
	pick_main_room()
	
	

func cull_rooms():
		for room in $Rooms.get_children():
			#if randf() < cull:
			if (room.size.x * room.size.y)/16 <= 6500:
					room.queue_free()
			else:
				room.freeze = true
		connect_rooms()
		await get_tree().create_timer(2).timeout
		rooms_connected = true


func connect_rooms():
	var delaunay = Delaunay.new()
	for room in $Rooms.get_children():
			delaunay.add_point(room.position)
	
	triangles = delaunay.triangulate()
	
	
	return triangles

func pick_main_room():
	for room in $Rooms.get_children():
		if randf() <= 0.05:
			room.is_main = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		for n in $Rooms.get_children():
			n.queue_free()
		rooms_connected = false
		make_rooms()


func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size*2), Color(32, 228, 0), false)
	#draw_line(connect_rooms().pop_front().center,connect_rooms().pop_back().center,Color.GREEN, 20)
	
	if rooms_connected:
		for triangle in connect_rooms():
			var a = triangle.a
			for triangle_2 in connect_rooms():
				var b = triangle_2.a
				#if a.distance_to(b) <= 5000:
					#b = a
				draw_line(a, b, Color.GREEN, 10)
	
	
func _process(delta):
	queue_redraw()
