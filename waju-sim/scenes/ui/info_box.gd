extends CanvasLayer

const VERSION_LABEL_DSR := "v1.1.1"
const VERSION_LABEL_FRU := "v1.8.1"
const VERSION_LABEL_DMU := "v0.2.0"

@onready var coords_label: Label = %CoordsLabel
@onready var fps_label: Label = %FPSLabel
@onready var version_label: Label = %VersionLabel

var player: Player


func _ready() -> void:
	GameEvents.party_ready.connect(on_party_ready)
	if !visible:
		set_process(false)
	var version_label_text = ProjectSettings.get_setting("rendering/rendering_device/driver")
	match Global.encounter:
		Global.Encounter.DSR:
			version_label_text = VERSION_LABEL_DSR + "\n" + version_label_text
		Global.Encounter.FRU:
			version_label_text = VERSION_LABEL_FRU + "\n" + version_label_text
		Global.Encounter.DMU:
			version_label_text = VERSION_LABEL_DMU + "\n" + version_label_text
	version_label.set_text(version_label_text)

func _process(_delta: float) -> void:
	if !player:
		return
	var model_rotation: float = rad_to_deg(player.get_model_rotation().y)
	coords_label.text = str("%.2f" % player.position.x, ", ", "%.2f" % player.position.z,
		"\nAngle: %f" % (fposmod((model_rotation + 180), 360)))
	fps_label.text = str("FPS: ", Engine.get_frames_per_second())


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _on_visibility_changed() -> void:
	if visible:
		set_process(true)


func _on_info_button_pressed() -> void:
	pass # Replace with function body.
