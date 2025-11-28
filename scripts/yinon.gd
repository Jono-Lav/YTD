extends Interactable

func interact(body):
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/yinon.dialogue"))
