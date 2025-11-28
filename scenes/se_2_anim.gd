extends AnimationPlayer

var onceA :bool = false
var onceB :bool = false
var onceC :bool = false
func _process(delta: float) -> void:
	if Global.canDel and not onceA:
		onceA = true
		play("SE2/splitSE2")
	if Global.canStep and not onceB:
		onceB = true
		play("SE2/stepSE2")
	if Global.canDrawn and not onceC:
		onceC = true
		play("SE2/drawnSE2")
		
		
