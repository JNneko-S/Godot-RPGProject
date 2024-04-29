extends CharacterBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 120
const FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var Velocity = Vector2.ZERO
var roll_Vector = Vector2.DOWN
var stats = PlayerStats

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var swordHitbox = $HitboxPlvot/SwordHitbox

func _ready():
	self.stats.connect("no_health", queue_free)
	animationTree.active = true
	swordHitbox.knockback_vector = roll_Vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
	
		ROLL:
			roll_state(delta)
	
		ATTACK:
			attack_state(delta)
	


func _input(event):
	if event.is_action_pressed("EXIT"):
		get_tree().quit()
	

func move_state(delta):
	var input_Vector = Vector2.ZERO
	input_Vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_Vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_Vector = input_Vector.normalized()
	
	if input_Vector != Vector2.ZERO:
		roll_Vector = input_Vector
		animationTree.set("parameters/Idle/blend_position", input_Vector)
		animationTree.set("parameters/Run/blend_position", input_Vector)
		animationTree.set("parameters/Attack/blend_position", input_Vector)
		animationTree.set("parameters/Roll/blend_position", input_Vector)
		animationState.travel("Run")
		Velocity = Velocity.move_toward(input_Vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		Velocity = Velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_collide(Velocity * delta)
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	Velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	Velocity = Velocity * 0.85
	state = MOVE

func roll_state(delta):
	Velocity = roll_Vector * ROLL_SPEED
	animationState.travel("Roll")
	move_and_collide(Velocity * delta)


func _on_hurtbox_area_entered(area):
	$Hurtbox.health -= area.damage

func _on_Hurtbox_no_health():
	queue_free()
