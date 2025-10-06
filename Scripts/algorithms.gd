extends Node
'''
Este Script contiene los tres algoritmos, además del timer
'''

# Temporizador configurado desde el editor
@export var time_counter: Timer
@export var time_selected: float = 2.0

# Contenedores
@export var contedor_cpu: HBoxContainer
@export var contedor_queue: HBoxContainer

# Estado interno
var initial_total: int = 0        # cantidad de procesos que había al iniciar
var completed_count: int = 0     # cuántos ya terminaron
var is_running: bool = false



# -----------------------------------------------------
#  INICIA FCFS (se ejecuta una sola vez)
# -----------------------------------------------------
# `processes` debe ser el array que devuelve harvest_processes() (datos iniciales)
func run_fcfs(processes: Array) -> void:
	if is_running:
		print("⚠️ El algoritmo ya está en ejecución.")
		return

	# Guardamos cuántos procesos había al inicio (no cambia después)
	initial_total = processes.size()
	completed_count = 0
	is_running = true
	GlobalManager.is_running = true

	# Orden inicial (si quieres mantener FCFS por tiempo puedes ordenar aquí)
	processes.sort_custom(func(a, b): return a["time"] < b["time"])

	# Rellenamos visualmente CPU + Queue con el orden inicial
	apply_fcfs_results(processes)

	# Iniciamos el timer
	time_counter.wait_time = time_selected
	time_counter.start()
	print("▶️ FCFS iniciado con", initial_total, "procesos.")


# -----------------------------------------------------
#  Pone procesos (orden inicial) en CPU + queue
# -----------------------------------------------------
func apply_fcfs_results(sorted_processes: Array) -> void:
	var all_slots = contedor_cpu.get_children() + contedor_queue.get_children()
	
	# Limpiamos primero todos los slots visuales
	for slot in all_slots:
		_clear_slot(slot)
	
	# Rellenamos según el orden (CPU primero, luego queue)
	for i in range(min(sorted_processes.size(), all_slots.size())):
		var data = sorted_processes[i]
		var slot = all_slots[i]
		
		slot.icon.texture = data.get("texture", null)
		slot.process_name_text.text = data.get("name", "")
		slot.process_time_text.text = str(data.get("time", 0)) + " h"
		slot.current_name = data.get("name", "")
		slot.current_time = int(data.get("time", 0))


# -----------------------------------------------------
#  Busca y mueve el primer proceso disponible en la QUEUE al primer slot libre del CPU
#  — también borra la info del slot de queue de donde se tomó.
# -----------------------------------------------------
func _find_first_queue_slot_with_process() -> Control:
	for slot in contedor_queue.get_children():
		if slot.icon.texture != null and slot.current_time > 0:
			return slot
	return null


func _move_next_to_cpu() -> bool:
	# Buscar un slot vacío en CPU
	for cpu_slot in contedor_cpu.get_children():
		if cpu_slot.icon.texture == null:
			var qslot = _find_first_queue_slot_with_process()
			if qslot:
				# Copiar datos del queue slot al cpu slot
				cpu_slot.icon.texture = qslot.icon.texture
				cpu_slot.process_name_text.text = qslot.process_name_text.text
				cpu_slot.process_time_text.text = str(qslot.current_time) + " h"
				cpu_slot.current_name = qslot.current_name
				cpu_slot.current_time = qslot.current_time

				# Limpiar el slot de la cola (ya no debe verse)
				_clear_slot(qslot)
				print("🧩 Moved to CPU:", cpu_slot.current_name)
				return true
			else:
				# No hay procesos en queue
				return false
	# No hay slot vacío en CPU
	return false


# -----------------------------------------------------
#  Timer: cada tick reduce 1 unidad al primer proceso activo del CPU
# -----------------------------------------------------
func _on_timer_timeout() -> void:
	if not is_running:
		return

	# Si ya completamos todos los procesos iniciales, terminar
	if completed_count >= initial_total and initial_total > 0:
		print("✅ Todos los procesos han terminado.")
		time_counter.stop()
		is_running = false
		GlobalManager.is_running = false
		return

	# Ejecutar solo un proceso por tick: el primer slot de CPU que tenga trabajo
	var cpu_slots = contedor_cpu.get_children()
	var executed = false

	for slot in cpu_slots:
		if slot.icon.texture != null and slot.current_time > 0:
			# Reducir
			slot.current_time -= 1
			slot.process_time_text.text = str(slot.current_time) + " h"
			print("⌛ Ejecutando:", slot.current_name, "| Tiempo restante:", slot.current_time)
			executed = true

			# Si terminó, limpiar y aumentar contador completados
			if slot.current_time <= 0:
				print("✅ Proceso completado:", slot.current_name)
				_clear_slot(slot)
				completed_count += 1

				# Intentar llenar el CPU inmediatamente desde la queue
				_move_next_to_cpu()

			# Salimos: solo un proceso por tick
			break

	# Si no se ejecutó nada y hay procesos en queue → mover el siguiente (por ejemplo al inicio o si CPU quedó vacío)
	if not executed:
		# Intenta mover uno desde queue si hay
		if _move_next_to_cpu():
			# logrado mover uno, se ejecutará en el siguiente tick
			print("🔄 Se colocó un proceso en CPU desde la queue.")
		else:
			# No hay procesos en queue ni en CPU
			# Si aún faltan procesos por completar según initial_total, estamos "esperando" que el usuario coloque procesos en la queue
			if completed_count < initial_total:
				print("⏳ Esperando procesos en la queue... (completados:", completed_count, "/", initial_total, ")")
			else:
				# Ya completados
				print("🏁 Todos los procesos terminados.")
				time_counter.stop()
				is_running = false
				GlobalManager.is_running = false


# -----------------------------------------------------
#  Limpia visualmente un slot (CPU o Queue)
# -----------------------------------------------------
func _clear_slot(slot: Control) -> void:
	slot.icon.texture = null
	slot.process_name_text.text = ""
	slot.process_time_text.text = ""
	slot.current_name = ""
	slot.current_time = 0
