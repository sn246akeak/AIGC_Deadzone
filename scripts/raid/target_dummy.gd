extends Damageable

@export var cleanup_on_death := true

func _ready() -> void:
	super._ready()
	if cleanup_on_death:
		died.connect(queue_free)
