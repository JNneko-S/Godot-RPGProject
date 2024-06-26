extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func create_grass_effect():
	var grassEffect = GrassEffect.instantiate()
	var world = get_tree().current_scene
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position


func _on_hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
