extends Camera2D



func _on_X_grounded_updated(is_grounded):
	drag_margin_v_enabled = !is_grounded
