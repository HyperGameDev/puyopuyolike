class_name Component_pieceArea extends Component

@onready var area_main: Area3D = %Area_Main
@onready var area_cushion: Area3D = %Area_Cushion

var piece_added_to: Node3D

func _ready() -> void:
	area_main.area_entered.connect(_on_area_main_entered)
	area_main.area_exited.connect(_on_area_main_exited)
	area_cushion.area_entered.connect(_on_area_cushion_entered)

func _on_area_main_entered(area: Area3D) -> void:
	match area.name:
		"Ground":
			piece_added_to.ground_detected_by_main.emit()
			print("AREA: GROUND DETECTED by (",piece_added_to.name,")")

		"Wall_L":
			piece_added_to.walled_state = walled_states.LEFT

		"Wall_R":
			piece_added_to.walled_state = walled_states.RIGHT

		_:
			pass

func _on_area_main_exited(area: Area3D) -> void:
	match area.name:
		"Ground":
			piece_added_to.ground_undetected_by_main.emit()
			
		"Wall_L":
			piece_added_to.walled_state = walled_states.NEITHER

		"Wall_R":
			piece_added_to.walled_state = walled_states.NEITHER

		_:
			pass

func _on_area_cushion_entered(area: Area3D) -> void:
	if area.name == "Ground":
		piece_added_to.ground_detected_by_cushion.emit()
