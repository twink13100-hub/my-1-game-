extends VehicleBody3D

const MAX_ENGINE := 1800.0
const MAX_BRAKE := 42.0
const MAX_STEER := 0.42

func _physics_process(_delta: float) -> void:
    var throttle := Input.get_action_strength("accelerate")
    var reverse := Input.get_action_strength("brake")
    var steering := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")

    engine_force = throttle * MAX_ENGINE - reverse * MAX_ENGINE * 0.55
    brake = MAX_BRAKE if Input.is_action_pressed("brake") and throttle <= 0.05 else 0.0
    self.steering = steering * MAX_STEER
