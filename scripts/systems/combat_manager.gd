extends Node
class_name CombatManager

signal entity_killed(killer: Entity, victim: Entity)

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Unit:
		(node as Unit).attacked.connect(func(target): _on_attack(node, target))
	if node is Entity:
		(node as Entity).died.connect(func(): _on_died(node))

func _on_attack(attacker: Entity, victim: Entity) -> void:
	pass  # Hook for future effects (particles, sounds, etc.)

func _on_died(victim: Entity) -> void:
	# Find who attacked last — simple approach: emit signal when any entity dies
	entity_killed.emit(null, victim)
