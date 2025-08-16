extends TextureProgressBar

var _tw: Tween

func set_hp(v: int) -> void:
	v = clampi(v, int(min_value), int(max_value))
	if _tw and _tw.is_running():
		_tw.kill()
	_tw = create_tween().set_trans(Tween.TRANS_LINEAR)
	_tw.tween_property(self, "value", v, 0.25)
