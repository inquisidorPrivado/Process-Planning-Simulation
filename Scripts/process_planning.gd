#process_planning.gd
extends Control

#Este contenedor contiene los 7 slots para alojar procesos
@onready var process_slot_container:HBoxContainer = $Interface/VBoxContainer/ProcessQueue/VBoxContainer/HBoxContainer

# Número máximo de slots
const MAX_SLOTS: int = 7

func _ready() -> void:
	#Asigna la cantidad de veces que se ejecuta el for, de 1 a 7 veces
	var repeticiones: int = randi_range(1, 7)
	for i in range(repeticiones):
		var horas: int = randi_range(1, 8)
		var random_index:int = randi_range(1, 4)
		print("Index:", random_index)
		add_process(random_index, horas)


	#primer_proceso.choose_icon(random_index, horas)

func add_process(random_index: int, hours: int) -> void:
	# Recorremos los slots del contenedor
	for slot in process_slot_container.get_children():
		# Verifica si el slot está vacío (su textura está en null, o sin hijos)
		if slot.icon.texture == null:
			# Aquí asignamos la textura según el icono
			slot.choose_icon(random_index, hours)
			
			return


	# Si llega aquí, significa que no había slots disponibles
	print("No hay más espacio para procesos (máximo %d)" % MAX_SLOTS)


func _on_quit_pressed() -> void:
	get_tree().quit()

#Nueva simulación
func _on_change_context_pressed() -> void:
	GlobalManager.is_running = false
	GlobalManager.algorithm_index = 0
	get_tree().reload_current_scene()
