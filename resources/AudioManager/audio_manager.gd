extends Node

## Create a temporary AudioStreamPlayer
## which plays any SFX we want, then removes itself
## This is meant to be a singleton
func PlaySFX(stream: String):
	var StreamPlayer = AudioStreamPlayer.new()
	StreamPlayer.name = "SFX"
	StreamPlayer.stream = stream
	
	add_child(StreamPlayer)
	StreamPlayer.play()
	
	await StreamPlayer.finished
	StreamPlayer.queue_free()
 
