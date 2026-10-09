extends Node2D

var default_speed = 100
var speed = default_speed
var direction = Vector2(0, 1)
var screen_size = Vector2()
var window_size = Vector2(200, 200)

var is_idling = false
var idle_timer = 0.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	#print (window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position (Vector2(window_position))
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


func idle():
	idle_timer = randf_range(1.0, 3.0)
	is_idling = true
	
	if (randi() % 3) == 0:
		animated_sprite.play('idle')
		speed = 0
		
func maybe_idle():
	if randf() < 0.3:
		idle()
