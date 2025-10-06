#manager.gd
extends Node
'''
Este Script contiene el sistema que maneja el funcionamiento de los botones y la utilización
de algoritmos (pausa o corre el algoritmo)
'''

#Este algoritmo contiene los algoritmos, solo debemos enviarle lo que necesita desd3e este Script
@export var algorithms_node:Node

#Se instancia los contenedores, para revisar si hay procesos dentro de ellas
@export var contedor_cpu:HBoxContainer
@export var contedor_queue:HBoxContainer

#Aquí están las instancias de los botones
@export var run_simulation:Button
@export var pause_simulation:Button

#La variable que hace asigna el quantum al algoritmo Round Robin 
@export var quantum_text:Label

#Es la instancia del botón que cambia el algoritmo según al gusto del usuario
@export var algorithm_button:OptionButton

#Aquí se guarda el índice del algoritmo seleccionado
@onready var algorithm_selected:int = 0


func _ready() -> void:
	is_running_the_cpu()
	algorithm_button.select(0)

#Comprobar que el usuario pueda realizar cambios y se ejecuten
func is_running_the_cpu() -> void:
	if not GlobalManager.is_running:
		run_simulation.disabled =false 
		algorithm_button.disabled = false
		pause_simulation.disabled =true 
	else: #Si se comprueba que no está en funcionamiento
		#Se habilita la opción de correr el CPU
		#Y se trata de parar todo sin importar que ya esté en alto (para asegurar)
		run_simulation.disabled =true 
		algorithm_button.disabled = true
		pause_simulation.disabled =false 
		

#Se actualiza el quantum según se especifique una escena anterior a esta
func update_quantum_text():
	quantum_text.text = "QUANTUM: "+str(GlobalManager.quantum_number)


#Se selecciona el algoritmo y hacemos aparecer el label que contiene el texto del quantum
func _on_option_button_item_selected(index: int) -> void:
	match index:
		0,1:
			quantum_text.visible = false
		2:
			update_quantum_text()
			quantum_text.visible = true
	algorithm_selected = index


func get_process_data(process_node: Node) -> Dictionary:
	return {
		"name": process_node.current_name,
		"time": process_node.current_time,
		"texture": process_node.icon.texture
	}


#La funcion que recolecta los procesos de los dos contenedores y los guarde en un array 
#para luego enviarselos al algoritmo seleccionado para que los acomode
func harvest_processes() -> Array:
	# Este array contendrá todos los procesos encontrados
	var processes: Array = []
	
	# Recolectar los procesos de CPU
	for child in contedor_cpu.get_children():
		if child.current_time > 0:
			processes.append(get_process_data(child))

	# Recolectar los procesos de la cola
	for child in contedor_queue.get_children():
		if child.current_time > 0:
			processes.append(get_process_data(child))
	
	print("Procesos recolectados: ", processes)
	
	return processes




func _on_pause_simulation_pressed() -> void:
	GlobalManager.is_running = false
	is_running_the_cpu()


func _on_run_simulation_pressed() -> void:
	var processes = harvest_processes()
	if processes.is_empty():
		print("No hay procesos para ordenar")
		return
	
	match algorithm_selected:
		0: # FCFS
			#var sorted = algorithms_node.run_fcfs(processes)
			algorithms_node.run_fcfs(processes)
			#algorithms_node.apply_fcfs_results(sorted)
		1:
			print("SJF aún no implementado")
		2:
			print("Round Robin aún no implementado")
	
	GlobalManager.is_running = true
	is_running_the_cpu()
	
