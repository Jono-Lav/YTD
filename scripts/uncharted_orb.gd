extends Node3D

@onready var TransitionAnim : AnimationPlayer = $Transition
@onready var phoneCollected : RichTextLabel = $phoneCollected
@onready var tree = $trees
@onready var hollowDancer = $hollowDancer
var numbersCollected : int = 0

func _ready() -> void:
	TransitionAnim.play("fade_in")

func _process(delta: float) -> void:
	phoneCollected.text = " [wave freq=2.5 height=0][shake freq=0.5 width=10 height=10][b]Numbers collected "+str(numbersCollected)+"/3[/b][/shake][/wave]"
