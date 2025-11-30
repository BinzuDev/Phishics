extends Node


var minimalisticSurfJump : bool = false
var muteWhenUnfocused : bool = false

func _ready():
	%Settings.visible = false

func menu_is_visible():
	return %Settings.visible



func _process(delta):
	if muteWhenUnfocused:
		AudioServer.set_bus_mute(0, !get_window().has_focus())


func show_settings_menu():
	%Settings.visible = true
	%settingsTabs.current_tab = 0
	%settingsGoBack.grab_focus()
	


func _on_settings_go_back():
	GameManager.disableMenuControl = false
	#show the pause list unless you're on the title screen
	if GameManager.gamePaused:
		MenuManager.find_child("PauseList").visible = true
	GameManager.focusPreviousUI()
	%Settings.visible = false






 ## Graphics ##
var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)

func _on_UIscale_value_changed(value):
	var new_size := viewport_start_size
	new_size /= value #get in percents
	%UIscale.set_percentage(roundi(value*100))
	get_tree().root.set_content_scale_size(new_size)

func get_resolution():
	var viewport_render_size = get_viewport().size * get_viewport().scaling_3d_scale
	return "(%d × %d)" % [viewport_render_size.x, viewport_render_size.y]

func _on_3d_res_scale_value_changed(value):
	get_viewport().scaling_3d_scale = value
	%"3DresScale".set_custom_value(str(roundi(value*100)," % ", get_resolution() ))
	

func _on_always_top_toggled(toggled_on):
	get_window().always_on_top = toggled_on


	## Audio ##
func _on_master_volume_changed(value):
	AudioServer.set_bus_volume_linear(0, value)
	%masterVol.text = str(" ", int(value*100), "%")
	print("linear: ", AudioServer.get_bus_volume_linear(0), " db: ", AudioServer.get_bus_volume_db(0))
func _on_music_volume_changed(value):
	AudioServer.set_bus_volume_linear(4, value) #music bus
	%musicVol.set_percentage(int(value*100))
func _on_voice_volume_changed(value):
	AudioServer.set_bus_volume_linear(3, value) #rankUp bus
	%voiceVol.set_percentage(int(value*100))
	$Settings/settingsTabs/Audio/voicePreview.play()
func _on_tricks_volume_changed(value):
	AudioServer.set_bus_volume_linear(2, value*0.1) #tricks bus
	%trickVol.set_percentage(int(value*20))
	$Settings/settingsTabs/Audio/trickPreview.play()
func _on_sfx_volume_changed(value):
	AudioServer.set_bus_volume_linear(1, value) #fishsfx bus
	AudioServer.set_bus_volume_linear(5, value) #soundEffects bus
	%sfxVol.set_percentage(int(value*100))
	$Settings/settingsTabs/Audio/sfxPreview.play()

func _on_focus_mute_pressed(toggle):
	muteWhenUnfocused = toggle


func _master_volume_help_tip():
	MenuManager.set_help_tip("Set the global volume of the game's audio.")
	
