extends RigidBody3D

var damage: int = 10
var speed: float = 100.0
var lifetime: float = 5.0

var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = lifetime
	timer.autostart = true 
	timer.one_shot = true 
	add_child(timer) 
	
	timer.connect("timeout", _on_timeout)
	
	linear_velocity = -global_transform.basis.z * speed

func _on_timeout():
	queue_free()
