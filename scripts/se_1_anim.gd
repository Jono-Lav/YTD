extends AnimationPlayer

var onceA :bool = false
var onceB :bool = false
var onceC :bool = false
func _process(delta: float) -> void:
	if Global.canDel and not onceA:
		onceA = true
		play("SE1/splitSE1")
	if Global.canStare and not onceB:
		onceB = true
		play("SE1/stareSE1")
	if Global.canDrawn and not onceC:
		onceC = true
		play("SE1/drawnSE1")
		
		
