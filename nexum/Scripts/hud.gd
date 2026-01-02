extends Label

func _ready():
	# 1. Poner el texto inicial
	text = "0"
	# 2. Conectarnos a la señal de que emite GameData
	GameData.score_updated.connect(update_points)
	
	pivot_offset = size / 2

func update_points(new_points):
	text = str(new_points)
	
	pivot_offset = size / 2
	var tween = create_tween()
	# Aumentamos tamaño en 0.1s
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1).set_trans(Tween.TRANS_BACK)
	# Cambia a rojo durante 0.1s
	tween.parallel().tween_property(self, "modulate", Color.RED, 0.1)
	# Volvemos al estilo inicial
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.1)
