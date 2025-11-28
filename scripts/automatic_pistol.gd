extends Node3D

@export var fire_rate: float = 0.2 
@export var max_ammo: int = 10
@export var reload_time: float = 2.0

@onready var bullet_scene: PackedScene = preload("res://scenes/Pistol_Bullet.tscn")
@onready var bullet_spawn_point: Marker3D = $BulletSpawnPoint
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var fire_sound : AudioStreamPlayer3D = $Fire
@onready var reload_sound : AudioStreamPlayer3D = $Reload
@onready var noammo_sound : AudioStreamPlayer3D = $NoAmmo
@onready var label : RichTextLabel = $Label

var ammo: int = max_ammo
var timer
var clear_reload_timer
var reloading: bool = false
var once: bool = true

func _ready():
	timer = Timer.new()
	timer.wait_time = fire_rate
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)

	clear_reload_timer = Timer.new()
	clear_reload_timer.wait_time = 1.0
	clear_reload_timer.autostart = false
	clear_reload_timer.one_shot = true
	clear_reload_timer.connect("timeout", Callable(self, "_on_clear_reload_timeout"))
	add_child(clear_reload_timer)

	updateAmmo(ammo)

func _physics_process(_delta):
	if Input.is_action_pressed("fire") and timer.is_stopped() and not reloading:
		if ammo > 0:
			fire()
		else:
			noammo_sound.play()
			if once:
				once = false
				label.text = label.text + "[wave freq=3.5 height=0][shake freq=1.0 width=10 height=10][b]  RELOAD (R)[/b][/shake][/wave]"
			clear_reload_timer.start() 
	if Input.is_action_just_pressed("reload") and not reloading:
		once = true
		reload()

func fire():
	var bullet = bullet_scene.instantiate()
	fire_sound.play()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = bullet_spawn_point.global_position
	bullet.rotation = bullet_spawn_point.rotation
	
	updateAmmo(ammo - 1)
	
	timer.start()

func reload():
	if ammo < max_ammo:
		reloading = true
		reload_sound.play()
		await get_tree().create_timer(reload_time).timeout

		updateAmmo(max_ammo)
		reloading = false

func updateAmmo(new_ammo: int):
	ammo = new_ammo
	label.text = "[wave freq=3.5 height=0][shake freq=1.0 width=10 height=10][b]" + str(new_ammo) + "/" + str(max_ammo) + "[/b][/shake][/wave]"

func _on_clear_reload_timeout():
	if not reloading:
		updateAmmo(ammo)
		once = true
