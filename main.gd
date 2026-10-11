extends Node2D
"""
var default_speed = 100
var speed = default_speed
var direction = Vector2(1.3, 1.1)
var screen_size = Vector2()
var window_size = Vector2(200, 200)

# Ideling variables
var is_idling = false
var idle_timer = 0.0

# Fragging variables
var is_dragging = false
var drag_offset = Vector2()

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	#print (window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position (Vector2(window_position))
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_window_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2(new_window_pos))
		return
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = default_speed
			animated_sprite.play('walk')
		return
	
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		maybe_idle()
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()

func _ready() -> void:
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk")
	area.input_event.connect(_on_area_input)


func idle():
	idle_timer = randf_range(1.0, 3.0)
	is_idling = true
	
	if (randi() % 3) == 0:
		animated_sprite.play('idle')
		speed = 0
		
func maybe_idle():
	if randf() < 0.23456:
		idle()

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var window_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - window_pos
			animated_sprite.play('drag')
		else:
			is_dragging = false
			animated_sprite.play('walk')



# todo: pet which just follow the cursor

"""

# ----- REWORK -----

# Base variables
var is_idle = false
var idle_time_left = 0.0
var is_dragging = false
var drag_offset = Vector2()
var is_paused = false
var pause_action_time = 7.0
var pause_time_since_last = 0.0
var is_following_mouse = false

var default_speed = 100
var initial_direction = Vector2(1.3, 0.4)
#var direction = Vector2(1.3, 0.4)
var direction = initial_direction
var size_screen = Vector2()
var size_window = Vector2(DisplayServer.window_get_size())

var current_primary_animation = 'idle'
var menu = 'default'

#var default_speed = 300
var speed = default_speed

#var drag_pos_0 = 0.0
#var drag_pos_1 = 0.0

#var direction = Vector2(x: 1.15, y: 0.7)

#var current_press_action = 'drag'
#var drag_min_time_sec = 0.3

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
#@onready var shape = $Area2D/CollisionShape2D
@onready var popup = $PopupMenu
#@onready var popup_paused = $PausedMenu


func _ready():
	size_screen = Vector2(DisplayServer.screen_get_size())
	
	current_primary_animation = 'walk'
	sprite.play(current_primary_animation)
	#popup.add_item('hi', 0)
	popup.add_item('(un) pause', 0)
	#popup_paused.add_item('un pause', 0)
	#popup_paused.add_item('continue', 0)
	#popup_paused.add_item('resume', 0)
	popup.add_item('change direction', 1)

	
	area.input_event.connect(_on_area_input)
	popup.id_pressed.connect(_on_item_press)
	#popup_paused.id_pressed.connect(_on_pause_item_press)
	
	#print (size_screen)
	#print (size_window)


func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var window_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - window_pos
			sprite.play('drag') # dot _animation() for a reason: should remember the animation pre-drag
		else:
			reset_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			#if is_paused:
				#menu = 'pause'
			#	popup.add_item('resume', 0)
			#	popup.popup_on_parent(Rect2i(Vector2i(event.position), Vector2i.ZERO))
			#else:
				#menu = 'default'
			#	popup.add_item('pause', 0)
			popup.popup_on_parent(Rect2i(Vector2i(event.position), Vector2i.ZERO))
			
			
#func _on_item_press(id, menu = 'default'):
func _on_item_press(id):
	#if menu == 'default':
	if id == 0:
	#	print('Hello World!')
		if is_paused:
			is_paused = false
			#current_primary_animation = 'walk'
			#sprite.play(current_primary_animation)
			_animation('walk')
		else:
			is_paused = true
			#current_primary_animation = 'pause'
			#sprite.play(current_primary_animation)
			_animation('pause')
	if id == 1:
		switch_direction()
		
		
func _process(delta: float):
	var window_position = Vector2(DisplayServer.window_get_position())
	
	if !is_paused: window_position += direction * speed * delta
	
	window_position.x = clamp(window_position.x, 0, size_screen.x - size_window.x)
	window_position.y = clamp(window_position.y, 0, size_screen.y - size_window.y)
	DisplayServer.window_set_position (Vector2(window_position))
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_window_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2(new_window_pos))
		#drag_pos_1 = drag_pos_0
		#drag_pos_0 = mouse_pos.x
		
		if drag_offset.x > 0:
			direction.x = initial_direction.x
		elif drag_offset.x < 0:
			direction.x = -initial_direction.x
		else:
			print('Something dragging offset related')
		
		#if _drag_pos_set() && drag_pos_1 > drag_pos_0:

		return
	elif is_idle && !is_paused:
		_idle(delta)
		
	if window_position.x <= 0 or window_position.x >= size_screen.x - size_window.x:
		switch_direction("x")
	if window_position.y <= 0 or window_position.y >= size_screen.y - size_window.y:
		switch_direction("y")


func switch_direction(axis = "x"):
	if axis == "x":
		direction.x *= -1
		sprite.flip_h = !sprite.flip_h
	elif axis == "y":
		direction.y *= -1
	else:
		return
		
func _idle(delta):
	idle_time_left -= delta
	if idle_time_left <= 0:
		is_idle = false
		#current_primary_animation = 'walk'
		#sprite.play(current_primary_animation)
		_animation('walk')
	return

func idle():
	is_idle = true
	idle_time_left = randf_range(randf_range(0.7, 1.3), randf_range(2.1, 5.0))
	#current_primary_animation = 'idle'
	#sprite.play(current_primary_animation)
	_animation('idle')
	
func _animation(animation):
		current_primary_animation = animation
		sprite.play(current_primary_animation)

func reset_drag():
	is_dragging = false
	sprite.play(current_primary_animation)
#	drag_pos_0 = 0.0
#	drag_pos_1 = 0.0
#func _drag_pos_set():
#	return(drag_pos_0 != 0.0 && drag_pos_1 != 0.0)



#"""
