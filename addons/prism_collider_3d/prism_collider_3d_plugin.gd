@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"PrismCollider3D",
		"CollisionShape3D",
		preload("res://addons/prism_collider_3d/prism_collider_3d.gd"),
		null
	)

func _exit_tree() -> void:
	remove_custom_type("PrismCollider3D")
