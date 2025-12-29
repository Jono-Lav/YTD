extends AnimationPlayer

var onceA :bool = false
var onceB :bool = false
func _process(delta: float) -> void:
	if Global.StartTextAnim and not onceA:
		onceA =true
		play("SE/head1")
	if Global.PearAnim and not onceB:
		onceB =true
		play("SE/pear")
		await get_tree().create_timer(1.5).timeout
		Global.canDel=true

		
