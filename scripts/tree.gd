extends Interactable

@onready var anim : AnimationPlayer = $anim
@onready var shakeSound : AudioStreamPlayer3D = $shakeSound
@onready var restoreSound : AudioStreamPlayer3D = $restoreSound
@onready var trees : Node =  get_node("/root/" + get_tree().current_scene.name + "/trees")
@onready var collision1 : CollisionShape3D = $collision1
@onready var collision2 : CollisionShape3D = $collision2
@onready var coll1 : CollisionShape3D = $"../col1"
@onready var coll2 : CollisionShape3D = $"../col2"
@onready var root : Node3D = $"../../.."

var location : Vector3
var elapsed_time: float = 0.0
var restore_time : float = 30.0
var down_time : float = 42.0
var goingdown : bool = false
var goingup : bool = false
var t

func _ready() -> void:
	location = self.position

func interact(body):
	goingup = true
	goingdown = false
	anim.stop()
	shakeSound.stop()
	restoreSound.play()
	collision1.disabled = true
	collision2.disabled = true
	coll1.disabled = false
	coll2.disabled = false
	await get_tree().create_timer(5).timeout
	trees.down()

func down():
	coll1.disabled = true
	coll2.disabled = true
	collision1.disabled = false
	collision2.disabled = false
	anim.play("shake")
	shakeSound.play()
	goingdown = true
	await get_tree().create_timer(5).timeout
	if goingdown:
		await get_tree().create_timer(5).timeout
		trees.down()
		Global.treesDown += 1
		root.hollowDancer.move()
		queue_free()

func _process(delta: float) -> void:
	if goingdown or goingup:
		elapsed_time += delta
		if goingdown:
			t = clamp(elapsed_time / down_time, 0, 1)
			self.position.y = lerp(location.y, location.y-5.8, t)
		else:
			t = clamp(elapsed_time / restore_time, 0, 1)
			self.position.y = lerp(self.position.y, location.y, t)
		if t >= 1.0:
			goingup = false
