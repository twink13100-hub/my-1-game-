extends Node3D

const CAR_SCRIPT = preload("res://scripts/vehicle.gd")
var car: VehicleBody3D
var camera: Camera3D
var speed_label: Label
var touch_buttons := {}

func _ready() -> void:
    _make_world()
    _make_car()
    _make_ui()

func _make_world() -> void:
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52, -28, 0)
    sun.light_energy = 1.2
    add_child(sun)

    var ground := StaticBody3D.new()
    ground.name = "Ground"
    add_child(ground)
    var ground_mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(240, 240)
    ground_mesh.mesh = plane
    var grass := StandardMaterial3D.new()
    grass.albedo_color = Color(0.25, 0.42, 0.22)
    ground_mesh.material_override = grass
    ground.add_child(ground_mesh)
    var ground_shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(240, 0.5, 240)
    ground_shape.shape = box
    ground_shape.position.y = -0.25
    ground.add_child(ground_shape)

    _make_box(Vector3(0, 0.05, -18), Vector3(14, 0.2, 100), Color(0.16, 0.17, 0.18), true)
    # Road markings
    for z in range(-64, 35, 8):
        _make_box(Vector3(0, 0.17, z), Vector3(0.22, 0.025, 3.5), Color(0.92, 0.88, 0.62), false)

    # Crash-test obstacles and ramps
    _make_box(Vector3(0, 0.8, -32), Vector3(2.8, 1.6, 1.1), Color(0.85, 0.22, 0.12), true)
    _make_box(Vector3(-4.3, 0.65, -44), Vector3(2.2, 1.3, 2.2), Color(0.92, 0.58, 0.12), true)
    _make_ramp(Vector3(4.2, 0, -25))
    # Simple low barriers
    for z in range(-60, 20, 8):
        _make_box(Vector3(-7.1, 0.45, z), Vector3(0.35, 0.9, 6), Color(0.8, 0.8, 0.78), true)
        _make_box(Vector3(7.1, 0.45, z), Vector3(0.35, 0.9, 6), Color(0.8, 0.8, 0.78), true)

func _make_box(pos: Vector3, size: Vector3, color: Color, collision: bool) -> void:
    var root: Node3D
    if collision:
        root = StaticBody3D.new()
    else:
        root = Node3D.new()
    root.position = pos
    add_child(root)
    var mesh := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = size
    mesh.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.88
    mesh.material_override = mat
    root.add_child(mesh)
    if collision:
        var cs := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        cs.shape = shape
        root.add_child(cs)

func _make_ramp(pos: Vector3) -> void:
    var body := StaticBody3D.new()
    body.position = pos
    body.rotation_degrees.x = -13
    add_child(body)
    var mesh := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(4, 0.35, 7)
    mesh.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 0.35, 0.72)
    mesh.material_override = mat
    body.add_child(mesh)
    var cs := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = bm.size
    cs.shape = shape
    body.add_child(cs)

func _make_car() -> void:
    car = VehicleBody3D.new()
    car.name = "PlayerCar"
    car.position = Vector3(0, 1.25, 8)
    car.mass = 1150
    car.engine_force = 0.0
    car.script = CAR_SCRIPT
    add_child(car)

    var body_mesh := MeshInstance3D.new()
    var body_box := BoxMesh.new()
    body_box.size = Vector3(1.8, 0.55, 3.5)
    body_mesh.mesh = body_box
    var paint := StandardMaterial3D.new()
    paint.albedo_color = Color(0.12, 0.42, 0.92)
    paint.metallic = 0.25
    paint.roughness = 0.35
    body_mesh.material_override = paint
    body_mesh.position.y = 0.45
    car.add_child(body_mesh)

    var cabin := MeshInstance3D.new()
    var cabin_box := BoxMesh.new()
    cabin_box.size = Vector3(1.35, 0.52, 1.55)
    cabin.mesh = cabin_box
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color(0.08, 0.14, 0.2)
    glass.metallic = 0.15
    cabin.material_override = glass
    cabin.position = Vector3(0, 0.95, -0.15)
    car.add_child(cabin)

    _make_wheel(Vector3(-0.95, 0.15, -1.12), "FrontLeft")
    _make_wheel(Vector3(0.95, 0.15, -1.12), "FrontRight")
    _make_wheel(Vector3(-0.95, 0.15, 1.12), "RearLeft")
    _make_wheel(Vector3(0.95, 0.15, 1.12), "RearRight")

    camera = Camera3D.new()
    camera.position = Vector3(0, 4.5, 8.5)
    camera.rotation_degrees = Vector3(-18, 0, 0)
    camera.current = true
    car.add_child(camera)

func _make_wheel(pos: Vector3, wheel_name: String) -> void:
    var wheel := VehicleWheel3D.new()
    wheel.name = wheel_name
    wheel.position = pos
    wheel.wheel_radius = 0.38
    wheel.wheel_rest_length = 0.18
    wheel.suspension_travel = 0.2
    wheel.suspension_stiffness = 24.0
    wheel.damping_compression = 2.8
    wheel.damping_relaxation = 3.5
    wheel.use_as_steering = wheel_name.begins_with("Front")
    wheel.use_as_traction = true
    car.add_child(wheel)
    var visual := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 0.34
    cylinder.bottom_radius = 0.34
    cylinder.height = 0.22
    visual.mesh = cylinder
    visual.rotation_degrees.z = 90
    var rubber := StandardMaterial3D.new()
    rubber.albedo_color = Color(0.06, 0.06, 0.065)
    visual.material_override = rubber
    wheel.add_child(visual)

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(16, 14)
    panel.custom_minimum_size = Vector2(260, 74)
    layer.add_child(panel)
    var vbox := VBoxContainer.new()
    panel.add_child(vbox)
    var title := Label.new()
    title.text = "CRASHDRIVE 3D  •  PROTOTYPE"
    title.add_theme_font_size_override("font_size", 16)
    vbox.add_child(title)
    speed_label = Label.new()
    speed_label.text = "Speed: 0 km/h"
    vbox.add_child(speed_label)
    var hint := Label.new()
    hint.text = "Keyboard: WASD / arrows • R = reset"
    vbox.add_child(hint)

    _add_touch_button(layer, "◀", Vector2(24, -122), "steer_left")
    _add_touch_button(layer, "▶", Vector2(116, -122), "steer_right")
    _add_touch_button(layer, "▲", Vector2(-156, -122), "accelerate", true)
    _add_touch_button(layer, "■", Vector2(-64, -122), "brake", true)

func _add_touch_button(layer: CanvasLayer, label_text: String, offset: Vector2, action: String, right_side := false) -> void:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(78, 78)
    button.add_theme_font_size_override("font_size", 28)
    button.modulate = Color(1, 1, 1, 0.84)
    layer.add_child(button)
    # Position from bottom-left or bottom-right, responsive to current viewport.
    if right_side:
        button.anchor_left = 1.0
        button.anchor_right = 1.0
        button.anchor_top = 1.0
        button.anchor_bottom = 1.0
        button.position = Vector2(offset.x, offset.y)
    else:
        button.anchor_top = 1.0
        button.anchor_bottom = 1.0
        button.position = Vector2(offset.x, offset.y)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))

func _process(_delta: float) -> void:
    if is_instance_valid(car):
        var kmh := int(car.linear_velocity.length() * 3.6)
        speed_label.text = "Speed: %d km/h" % kmh
        if Input.is_action_just_pressed("reset_car"):
            car.global_position = Vector3(0, 1.5, 8)
            car.rotation = Vector3.ZERO
            car.linear_velocity = Vector3.ZERO
            car.angular_velocity = Vector3.ZERO
