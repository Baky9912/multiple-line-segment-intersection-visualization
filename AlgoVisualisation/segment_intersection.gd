extends Node2D

class Intersection:
	var pos: Vector2
	var l1: TwoPLine
	var l2: TwoPLine
	func _init(_p: Vector2, _l1: TwoPLine, _l2: TwoPLine):
		pos = _p
		if _l1.s.real_pos.x < _l2.s.real_pos.x:
			l1 = _l1
			l2 = _l2
		else:
			l1 = _l2
			l2 = _l1
			
	func _to_string():
		return "{Intersection pos="+str(round(pos*100)/100)+", l1="+str(l1)+", l2="+str(l2)+"}"

	func equals(oi: Intersection) -> bool:
		return l1==oi.l1 and l2==oi.l2

class Event:
	var y: float
	func _init(_y: float):
		y = _y

class EventEnter extends Event:
	var l: TwoPLine
	var p : Point2D
	func _init(_y: float, _l: TwoPLine, _p: Point2D):
		super(_y)
		l = _l
		p = _p
	func _to_string():
		return "{EEnter y=" + str(round(y*100)/100) + ", l=" + str(l) + "}"
	
class EventExit extends Event:
	var l: TwoPLine
	var p : Point2D
	func _init(_y: float, _l: TwoPLine, _p: Point2D):
		super(_y)
		l = _l
		p = _p
	func _to_string():
		return "{EExit y=" + str(round(y*100)/100) + ", l=" + str(l) + "}"
		
class EventIntersection extends Event:
	var intersection: Intersection
	func _init(_y: float, _intersection: Intersection):
		super(_y)
		intersection = _intersection
	func _to_string():
		var tmp = str(intersection)
		return "{E"+tmp.substr(1)
		
var intersections = Array()
var lines = Array()

func add_important_text(rtl: RichTextLabel, prefix: String,
arr: Array, important: Array):
	rtl.clear()
	rtl.push_color(Color.BLACK)
	rtl.add_text(prefix)
	rtl.add_text("[")
	for e in arr:
		if important.find(e)!=-1:
			#print("IMPORTANT FOUND!", e)
			rtl.push_color(Color.RED)
			rtl.add_text(str(e))
			rtl.pop()
		else:
			rtl.add_text(str(e))
		if e != arr.back():
			rtl.add_text(", ")
	rtl.add_text("]")
	rtl.pop()


func mark_intersections():
	# O(N^2) algo
	intersections.clear()
	var n = lines.size()
	var l1 : TwoPLine
	var l2 : TwoPLine
	print(n)
	for i in n:
		l1 = lines[i]
		for j in range(i+1, n):
			l2 = lines[j]
			var p = l1.line_intersection_point(l2)
			if p is Vector2:
				print("INTERSECTION ", l1.s.get_label(), " ", l2.s.get_label(), " ",p)
				var point = point_spawner.add_point8_nolabel(p)
				point.self_modulate = Color.RED

var events: Array = Array() # sorted by y
var ordered_lines: Array = Array() # sorted by current x
@onready var sweep_line: ColorRect = get_node("ColorRect/SweepLine")
@onready var color_rect: ColorRect = get_node("ColorRect")
@onready var point_spawner = PointSpawner.new(get_node("ColorRect"))
@onready var line_spawner = LineSpawner.new(get_node("ColorRect"))


func _ready():
	lines.append_array(line_spawner.draw_random_lines(
		Global.random_line_count, Global.rng_seed, Global.line_mean_length))
	#for line in lines:
	#	print(line, " ", line.s.real_pos, " ", line.t.real_pos)
	setup_line_events()


var inserted_events = Array()
var removed_events = Array()
var inserted_lines = Array()
var removed_lines = Array()


func _process(delta):
	if not Global.play:
		return
	if sweep_line.position.y > color_rect.size.y:
		return
	var stop_y = 10000.0 if events.is_empty() else events.front().y-2
	sweep_line.position.y = min(sweep_line.position.y + Global.speed*delta, stop_y)
	if not events.is_empty() and sweep_line.position.y+2 >= events.front().y:
		process_top_event()
		#print("INSERTED EVENTS\n------------------\n")
		#print(inserted_events)
		add_important_text($ColorRect2/LinesRTB, "Lines: ", ordered_lines, inserted_lines)
		add_important_text($ColorRect2/EventsRTB, "Events: ", events, inserted_events)
		add_important_text($ColorRect2/RemovedLinesRTB, "Removed lines: ", removed_lines, [])
		add_important_text($ColorRect2/RemovedEventsRTB, "Removed events: ", removed_events, [])
		if Global.pause_on_event:
			Global.play = false
		else:
			set_process(false)
			await get_tree().create_timer(0.3 * 50 /Global.speed).timeout
			set_process(true)


func setup_line_events():
	for line in lines:
		setup_line_event(line)


func setup_line_event(l: TwoPLine):
	var top_point: Point2D = l.s
	var bottom_point: Point2D = l.t
	if top_point.real_pos.y > bottom_point.real_pos.y:
		top_point = bottom_point
	var entry = EventEnter.new(top_point.real_pos.y, l, top_point)
	insert_event(entry)

	

func insert_event(e: Event):
	inserted_events.append(e)
	var n = len(events)
	var pos = n
	for i in n:
		if e.y < events[i].y:
			pos = i
			break
	events.insert(pos, e)


func find_largest_smaller_x(entry_x: float, y: float):
	var l: int = 0
	var r: int = len(ordered_lines)-1
	var best: int = 0
	var m: int
	while l<=r:
		@warning_ignore("integer_division")
		m = (l+r)/2
		var other_x: float = ordered_lines[m].line_eq.solve_x(y)
		if entry_x >= other_x:
			l=m+1
			best=m
		else:
			r=m-1
	return best


func process_top_event():
	inserted_events.clear()
	removed_events.clear()
	inserted_lines.clear()
	removed_lines.clear()
	
	var e = events.pop_front()
	removed_events.append(e)
	
	if e is EventEnter:
		inserted_lines.append(e.l)
		#print("Found EventEnter")
		var bottom_point = e.l.t if e.p == e.l.s else e.l.s
		var exit = EventExit.new(bottom_point.real_pos.y, e.l, bottom_point)
		insert_event(exit)
		
		# solve for y in binary tree ordered_lines
		# insert line and find neighbours
		if ordered_lines.is_empty():
			ordered_lines.append(e.l)
		elif e.l.line_eq.solve_x(e.y) < ordered_lines.front().line_eq.solve_x(e.y):
			ordered_lines.push_front(e.l)
			process_possible_intersection(ordered_lines[0], ordered_lines[1], e.y)
		else:
			var entry_x: float = e.l.line_eq.solve_x(e.y)
			var k = find_largest_smaller_x(entry_x, e.y)
			
			remove_possible_intersection(k, e.y)
			ordered_lines.insert(k+1, e.l)
			process_possible_intersection(ordered_lines[k], ordered_lines[k+1], e.y)
			if k+2 < len(ordered_lines):
				process_possible_intersection(ordered_lines[k+1], ordered_lines[k+2], e.y)
				
		# PROCESS POSSIBLE INTERACTIONS
	elif e is EventExit:
		removed_lines.append(e.l)
		#print("Found EventExit")
		var i = ordered_lines.find(e.l)
		ordered_lines.pop_at(i)
		if len(ordered_lines) >= 2 and i<len(ordered_lines):
			#print(ordered_lines)
			#print(ordered_lines[i-1], ordered_lines[i])
			process_possible_intersection(ordered_lines[i-1], ordered_lines[i], e.y)
			
	elif e is EventIntersection:
		point_spawner.add_point8_nolabel(e.intersection.pos).self_modulate = Color.RED
		#print("Found EventIntersection")
		var i = ordered_lines.find(e.intersection.l1)
		var j = ordered_lines.find(e.intersection.l2, max(i-1, 0))
		
		if i>j:
			var tmp = i
			i=j
			j=tmp
		
		remove_possible_intersection(i-1, e.y)
		remove_possible_intersection(i+1, e.y)
		
		var tmp = ordered_lines[i]
		ordered_lines[i] = ordered_lines[j]
		ordered_lines[j] = tmp
		
		if i>0:
			process_possible_intersection(ordered_lines[i], ordered_lines[i-1], e.y)
		if j+1 < len(ordered_lines):
			process_possible_intersection(ordered_lines[j], ordered_lines[j+1], e.y)


func process_possible_intersection(l1: TwoPLine, l2: TwoPLine, sweep_y: float):
	var pos = l1.line_intersection_point(l2)
	if pos is Vector2 and pos.y >= sweep_y:
		#print(l1, l2)
		var intersection = Intersection.new(pos, l1, l2)
		var ei: EventIntersection = EventIntersection.new(pos.y, intersection)
		#print("Adding ", ei)
		insert_event(ei)


func remove_possible_intersection(i: int, sweep_y: float):
	if not (i+1<len(ordered_lines) and i>=0):
		return null
	var l1: TwoPLine = ordered_lines[i]
	var l2: TwoPLine = ordered_lines[i+1]
	var pos = l1.line_intersection_point(l2)
	if pos is Vector2 and pos.y >= sweep_y:
		var intersection = Intersection.new(pos, l1, l2)
		var ei: EventIntersection = EventIntersection.new(pos.y, intersection)
		var j = -1
		for k in len(events):
			if events[k] is EventIntersection and intersection.equals(events[k].intersection):
				j=k
				break
		#print("removing intersection: ", ei, "at ", j)
		removed_events.append(events[j])
		events.remove_at(j)
		#print("Adding ", ei)
		
	
# after event is reached stop the animation 
# process the event
# pause for 0.1s and wait for next event to be reached

# TODO add stop/resume button
# add stop on event toggle
