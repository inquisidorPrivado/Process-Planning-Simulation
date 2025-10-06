#process.gd
extends Panel

@onready var process_name_text:Label = $PanelContainer/ProcessImage/ProcessName
@onready var process_time_text:Label = $PanelContainer/ProcessImage/ProcessTime
@onready var icon:TextureRect = $PanelContainer/ProcessImage

@onready var images : Dictionary = {
	1 : ["res://Sprites/balatro.jpg", "Balatro"],
	2 : ["res://Sprites/cuphead.jpg", "Cuphead"],
	3 : ["res://Sprites/deadcells.jpg", "Dead Cells"],
	4 : ["res://Sprites/silksong.jpg", "Silksong"]
}

var current_name:String = ""
var current_time:int = 0

func update_time_text() -> void:
	process_time_text.text = str(current_time) + " h"


func choose_icon(random_index:int, hours:int) -> void:
	current_name = images[random_index][1]
	current_time = hours
	
	icon.texture = load(images[random_index][0])
	process_name_text.text = current_name
	process_time_text.text = str(current_time) + " h"

# ---- DRAG & DROP ----
func _get_drag_data(_at_position: Vector2) -> Variant:
	if icon.texture == null:
		return
	
	# Paquete de datos + origen
	var drag_data = {
		"texture": icon.texture,
		"name": current_name,
		"time": current_time,
		"origin": self
	}
	
	# Vista previa
	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(25,25)
	preview.self_modulate = Color.TRANSPARENT
	c.modulate = Color(c.modulate, 0.5)
	
	set_drag_preview(c)
	return drag_data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("texture")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var origin = data["origin"]
	if origin == self:
		return # No hacemos nada si se suelta en el mismo panel
	
	# Guardamos los datos actuales del destino (por si toca swap)
	var old_texture = icon.texture
	var old_name = current_name
	var old_time = current_time
	
	# Asignamos al destino los datos del origen
	icon.texture = data["texture"]
	process_name_text.text = data["name"]
	process_time_text.text = str(data["time"]) + " h"
	current_name = data["name"]
	current_time = data["time"]
	
	# Si el destino estaba vacío → solo vaciamos el origen
	if old_texture == null:
		origin.icon.texture = null
		origin.process_name_text.text = ""
		origin.process_time_text.text = ""
		origin.current_name = ""
		origin.current_time = 0
	else:
		# Si el destino ya tenía algo → swap (poner lo viejo en el origen)
		origin.icon.texture = old_texture
		origin.process_name_text.text = old_name
		origin.process_time_text.text = str(old_time) + " h"
		origin.current_name = old_name
		origin.current_time = old_time
