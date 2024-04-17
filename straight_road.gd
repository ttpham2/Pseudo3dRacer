extends Node2D


const SEGMENT_NUM = 500
const SEGMENT_LENGTH = .25
const RUMBLE_LENGTH = 5
const LANE_LENGTH = 3
const ROAD_WIDTH = 500
const POV_Y = 60.0
const POV_Z = 10.0
const SCALE = .5

@export var lanes_number = 3
@export var field_of_view = 50
@export var lane_color:Color
@export var rumble_color:Color
@export var road_color:Color
@export var rumble_one_color:Color
@export var rumble_two_color:Color
@export var ground_color:Color
var screen
var center
#distance from camera to car
var z_position
#camera height
var screen_height
var screen_width
var track_length = null
var camera_height = 1
var camera_depth = null
var player_x = 0
var player_z = null
var screen_height_scale:float
var scaling
var segments = []
var rendered = 0

func _ready():
	screen = get_viewport_rect().size
	#print(screen.x)
	#print(screen.y)
	center = Vector2(screen.x/2, screen.y/2)
	z_position = 0
	screen_height_scale = screen.y * SCALE
	screen_height = screen.y
	screen_width = screen.x
	reset()
	reset_road()


func _process(float):
	queue_redraw()


func _draw():
	#render_segment(screen_width,lanes_number,0,200,100,0,100,50,Color.GRAY)
	var base_segment = find_segment(z_position)
	var min_y = -(screen_height / 2);
	var segment
	for n in range(0, SEGMENT_NUM):
		segment = segments[(base_segment.index + n) % segments.size()]
		project(segment.p1, (player_x * ROAD_WIDTH), camera_height, z_position, camera_depth, screen_width, screen_height, ROAD_WIDTH)
		project(segment.p2, (player_x * ROAD_WIDTH), camera_height, z_position, camera_depth, screen_width, screen_height, ROAD_WIDTH)
		
		#if n == 0:
			#segment.p1.screen.y = screen_height / 2
			#segment.p1.screen.w = screen_width
		#if((segment.p1.camera.z <= camera_depth)) || (segment.p2.screen.y <= min_y):
			#continue
			
		if(segment.p2.screen.y <= min_y):
			continue
		render_segment(screen_width,lanes_number,
						segment.p1.screen.x,
						segment.p1.screen.y,
						segment.p1.screen.w,
						segment.p2.screen.x,
						segment.p2.screen.y,
						segment.p2.screen.w,
						segment.color)
		rendered += 1
		#min_y = -segment.p2.screen.y
			
		#project(segment.p1, playerX * road)
	#print(typeof(screen_height_scale))
	#Calculate segments vertical position
	#for n in range(0,SEGMENT_NUM):
		##print(segments[1])
		##segments.append(1)
		#segments.append( screen_height_scale * ((n * SEGMENT_LENGTH * POV_Y) / POV_Z) / (1 + (n * SEGMENT_LENGTH)))
	
	#Draw segments vertical separators
	#draw_line(Vector2(-540,0),Vector2(540,0),Color.GREEN)
	#render_polygon(-100,-100,10,10,10,0,0,0,Color.GREEN)
	#render_segment(screen_width,lanes_number,
						#segment.p1.screen.x,
						#segment.p1.screen.y,
						#segment.p1.screen.w,
						#segment.p2.screen.x,
						#segment.p2.screen.y,
						#segment.p2.screen.w,
						#segment.color)
	#render_segment(screen_width,lanes_number,0,439,214,0,28,107,Color.GRAY)
	#print(screen.y)
	#for n in SEGMENT_NUM:
		#draw_line(Vector2(-540,(screen.y / 2) - segments[n]),Vector2(540,(screen.y / 2) - segments[n]),Color.GREEN)
	
	#for n in range(n,SEGMENT_NUM)

func reset_road():
	segments = []
	for n in range(0,SEGMENT_NUM):
		segments.push_back({
			"index": n,
			"p1": { "world": { "z": n * SEGMENT_LENGTH}, "camera": {} , "screen": {}},
			"p2": { "world": { "z": (n + 1) * SEGMENT_LENGTH}, "camera": {} , "screen": {}},
			"color": {"rumble": rumble_one_color if floor(n / RUMBLE_LENGTH % 2) else rumble_two_color, 
					"lane": lane_color if floor(n / LANE_LENGTH % 2) else road_color}  
		})
		
	track_length = segments.size() * SEGMENT_LENGTH

func find_segment(z):
	return segments[int(floor(z / SEGMENT_LENGTH)) % segments.size()]
	
func project(p, cameraX, cameraY, cameraZ, cam_depth, w, h, roadWidth):
	#p.camera.x = (p.world.x || 0) - cameraX
	#p.camera.y = (p.world.y || 0) - cameraY
	#p.camera.z = (p.world.z || 0) - cameraZ
	p.camera.x = 0 - cameraX
	p.camera.y = 0 - cameraY
	p.camera.z = p.world.z - cameraZ
	#p.screen.scale = cam_depth / p.camera.z if (p.camera.z > 0) else .01
	p.screen.scale = (cam_depth / p.camera.z) if p.camera.z > 0 else 0
	#scaling = (x_resolution/2) / tan(fov_angle/2)
	
	#for moving road down scaled value
	var height_difference = h/2 - (SCALE * h / 2)
	
	p.screen.x = SCALE * roundf(p.screen.scale * p.camera.x * w / 2)
	#p.screen.x = roundf(w / 2) + roundf(p.camera.x * w / 2)
	p.screen.y = SCALE * -(roundf((h / 2) + (p.screen.scale * p.camera.y * h / 2))) + height_difference
	#p.screen.y = roundf((h / 2) + (p.camera.y * h / 2))
	#p.screen.w = (roundf(abs(p.screen.scale * roadWidth))) if p.screen.scale > 0 else roadWidth
	p.screen.w = SCALE * (roundf(p.screen.scale * roadWidth)) 
	#pass
	#p.screen.w = roadWidth * w / 2
	#p.screen.x = roundf(w / 2) + roundf((scaling) * p.camera.x * w / 2)
	#p.screen.y = roundf((h / 2) - ((scaling * p.camera.y * h / 2)))
	#p.screen.w = roundf((scaling) * roadWidth * w / 2)

func render_polygon(x1,y1,x2,y2,x3,y3,x4,y4,color):
	var point = [Vector2(int(x1),int(y1)), Vector2(int(x2),int(y2)),
				Vector2(int(x3),int(y3)), Vector2(int(x4),int(y4))]
	draw_primitive(PackedVector2Array(point), PackedColorArray([color,color,color,color]), 
					PackedVector2Array([]))


func render_segment(width,lanes,x1,y1,w1,x2,y2,w2,color):
	
	var r1 = rumble_width(w1, lanes)
	var r2 = rumble_width(w2, lanes)
	var l1 = lane_marker_width(w1, lanes)
	var l2 = lane_marker_width(w2, lanes)
	var lane_w1
	var lane_w2
	var lane_x1
	var lane_x2
	
	draw_rect(Rect2(-width / 2,y2, width,y1 - y2),ground_color)
	
	render_polygon(x1 - w1 - r1, y1, x1 - w1, y1, x2 - w2, y2, x2 - w2 - r2, y2, color.rumble)
	render_polygon(x1 + w1 + r1, y1, x1 + w1, y1, x2 + w2, y2, x2 + w2 + r2, y2, color.rumble)
	render_polygon(x1 - w1, y1, x1 + w1, y1, x2 + w2, y2, x2 - w2, y2, road_color)
	
	if(lane_color):
		lane_w1 = w1*2 / lanes
		lane_w2 = w2*2 / lanes
		lane_x1 = x1 - w1 + lane_w1
		lane_x2 = x2 - w2 + lane_w2
		for lane in range(1,lanes):
			render_polygon(lane_x1 - l1/2, y1, lane_x1 + l1/2, y1, lane_x2 + l2/2, y2, lane_x2 - l2/2, y2, color.lane)
			lane_x1 += lane_w1
			lane_x2 += lane_w2
	
	


func rumble_width(projected_road_width, lanes):
	return projected_road_width / max(6, 2 * lanes)
	
func lane_marker_width(projected_road_width, lanes):
	return projected_road_width / max(32, 8 * lanes)


func reset():
	scaling = tan(deg_to_rad(field_of_view/2))
	camera_depth = 1 / scaling
	#camera_depth = .85
	player_z = (camera_height * camera_depth)
#func render_fog
