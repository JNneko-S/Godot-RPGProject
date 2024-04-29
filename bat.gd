extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone

@export var ACCELERATION = 225 ##加速度
@export var MAX_SPEED = 25 ##最大速度
@export var FRICTION = 200 ##摩擦

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")

enum{
	IDLE,
	WANDER,
	CHASE
}

var VELOcity = Vector2.ZERO
var state = IDLE

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
	VELOcity = move_and_slide()


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_hurtbox_area_entered(area):
	var direction = area.get("knockback_vector")
	if direction != null:
		stats.health -= area.damage
	var knockback_vector = $Hurtbox.global_position - area.global_position
	knockback_vector = knockback_vector.normalized()
	velocity = knockback_vector * 100

func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
