extends Node


@export var text := ""
var timer := 0
var char := 0
var finished := true

func _process(delta):
	timer += 1
	if timer % 1 == 0 and !finished:
		%textBox.text += text[char]
		char += 1
		if char == text.length():
			finished = true

func set_text(newText: String):
	text = newText
	char = 0
	finished = false
	%textBox.text = ""
