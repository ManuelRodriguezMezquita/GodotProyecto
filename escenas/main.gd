extends Node3D

@onready var skeleton_3d: Skeleton3D = $XROrigin3D/PruebaGODOT4_0/Prueba01/Skeleton3D
@onready var mano_izquierda: XRController3D = $XROrigin3D/Mano_Izquierda
@onready var mano_derecha: XRController3D = $XROrigin3D/Mano_Derecha

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")

func _process(delta):
	# --- Mano izquierda ---
	var left_bone = skeleton_3d.find_bone("hand_l")
	if left_bone != -1:
		var rot = mano_izquierda.global_transform.basis
		var base_pose = skeleton_3d.get_bone_pose(left_bone)
		base_pose.basis = rot
		skeleton_3d.set_bone_pose(left_bone, base_pose)

	# --- Mano derecha ---
	var right_bone = skeleton_3d.find_bone("hand_r")
	if right_bone != -1:
		var rot = mano_derecha.global_transform.basis
		var base_pose = skeleton_3d.get_bone_pose(right_bone)
		base_pose.basis = rot
		skeleton_3d.set_bone_pose(right_bone, base_pose)

	# --- Cuerpo / raíz ---
	
	var root_bone = skeleton_3d.find_bone("pelvis")
	if root_bone != -1:
		var cam_transform = $XROrigin3D/XRCamera3D.global_transform

	# Obtener la pose actual del hueso raíz
		var current_pose = skeleton_3d.get_bone_pose(root_bone)

	# Separar solo la rotación Y de la cámara
		var camera_euler = cam_transform.basis.get_euler()
		var rot_y = camera_euler.y

	# Construir una base que solo gira en Y, manteniendo la base actual para X y Z
		var new_basis = Basis(Vector3.UP, rot_y)

	# Asignar solo la posición XZ y mantener la altura original
		var new_transform = Transform3D()
		new_transform.origin = Vector3(cam_transform.origin.x, current_pose.origin.y, cam_transform.origin.z)
		new_transform.basis = new_basis

		skeleton_3d.set_bone_global_pose_override(root_bone, new_transform, 1.0, true)
