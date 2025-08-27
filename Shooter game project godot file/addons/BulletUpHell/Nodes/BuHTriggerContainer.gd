@tool
extends Node
class_name TriggerContainer

@export_placeholder("ID") var id:String
@export_multiline var advanced_controls:String = ""
@export var triggers:Array[Trigger] = [null]
@export var patterns:Array[Resource] = [null]
@export var pool_amount:int = 50

var commands:Array = []


func _ready():
	if not (not Engine.is_editor_hint() and triggers != [null]): return
	for i:Trigger in triggers:
		if i.resource_name == "TrigCol" and i.target_to_collide:
			i.node_collide = get_node(i.target_to_collide)
		elif i.resource_name == "TrigPos" and i.target:
			i.node_target = get_node(i.target)
		Spawning.new_trigger(id+"/"+str(triggers.find(i)), i)
	for j:int in patterns.size(): Spawning.new_pattern(id+"/"+str(j), patterns[j])
	Spawning.new_container(self)
	
	if advanced_controls == "": advanced_controls = "0=0\n>q"
	commands = advanced_controls.split("\n", false)
	for line:int in commands.size():
		if "=" in commands[line]:
			commands[line] = commands[line].split("=",false)

func create_pool(shared_area_name:String, pool_amount:int):
	if pool_amount <= 0: return
	for p:Resource in patterns:
		var props:String = Spawning.pattern(p.bullet)["bullet"]
		var create_pool:Callable = Callable(Spawning, "create_object_pool") if Spawning.bullet(props).has("instance_id") \
							else Callable(Spawning, "create_pool")
		create_pool.call(props, pool_amount, shared_area_name)

func define_trigger(res:Array, t:String, b):
	var curr_t = Spawning.trigger(id+"/"+t)
	if not res.has(curr_t.resource_name): res.append(curr_t.resource_name)
	if curr_t.resource_name == "TrigTime":
		get_tree().create_timer(curr_t.time, false).connect("timeout",Callable(Spawning,"trig_timeout").bind(b))


func getCurrentTriggers(b):
	if b.get("trigger_counter") < 0: return
	var res:Array = []
	var list = commands[b.get("trigger_counter")][0]
	if "/" in list:
		list = list.split("/")
		for sublist in list:
			if "+" in list:
				sublist = sublist.split("+")
				for t in sublist: define_trigger(res, t, b)
			else: define_trigger(res, sublist, b)
	elif "+" in list:
		list = list.split("+")
		for t in list: define_trigger(res, t, b)
	else: define_trigger(res, list, b)
	return res


func resetTriggers(b):
	b.trig_signal = ""
	b.trig_collider = null
	b.trigger_timeout = false

func callAction(isNode:bool, b, pattern:String):
	if isNode: b.callAction()
	else: Spawning.spawn(b, pattern, b.get("shared_area").name)

func applyTrigger(b, list, counter:int, cond_index:int, isNode:bool):
	list = commands[counter][1]
	if "/" in list:
		list = list.split("/")
		if "+" in list:
			list = list.split("+")
			for p in list: callAction(isNode, b, id+"/"+p)
		else: callAction(isNode, b, id+"/"+list[Spawning.RAND.randi()%list.size()])
	elif "+" in list:
		list = list.split("+")
		for p in list: callAction(isNode, b, id+"/"+p)
	else: callAction(isNode, b, id+"/"+list)

func isTriggerChecked(list, b, isNode:bool) -> Array:
	var ok:bool = false
	var cond_index:int = 0
	if "/" in list:
		list = list.split("/")
		for sublist in list:
			var or_ok = true
			if "+" in sublist:
				ok = true
				sublist = sublist.split("+")
				for t in sublist: if not checkTrigger(b, t, isNode):
					or_ok = false
					break
			else: or_ok = checkTrigger(b, sublist, isNode)
			if not or_ok: cond_index += 1
			else:
				ok = true
				break
	elif "+" in list:
		ok = true
		list = list.split("+")
		for t in list: if not checkTrigger(b, t, isNode):
			ok = false
			break
	else: ok = checkTrigger(b, list, isNode)
	return [ok, cond_index]

func checkTriggers(b):
	if b["trigger_counter"] < 0: return false
	var trigger_counter:int
	if b is Dictionary: trigger_counter = b["trigger_counter"]
	elif b is Node: trigger_counter = b.trigger_counter
	
	var list = commands[trigger_counter][0]
	var isNode:bool = (b is Node)
	var trigger_result:Array = isTriggerChecked(list, b, isNode)
	if trigger_result[0]:
		applyTrigger(b, list, trigger_counter, trigger_result[1], isNode)
	
		if trigger_counter+1 < commands.size():
			updateBase(b, list, trigger_counter, isNode)
		else: return true

func updateBase(b, list, trigger_counter:int, isNode:bool):
	list = commands[trigger_counter+1].split(">")
	if list[0] != "":
		if not b.get("trig_iter").has(trigger_counter+1):
			b.get("trig_iter")[trigger_counter+1] = int(list[0])-1
		else: b.get("trig_iter")[trigger_counter+1] -= 1
		
		if b.get("trig_iter")[trigger_counter+1] > 0: b.trigger_counter = int(list[1])
		else: b.trigger_counter += 2
	elif list[1] != "":
		if list[1] == "q":
			if not isNode: Spawning.delete_bullet(b)
			else: b["RID"].queue_free()
			return
		elif list[1] == "|": b.trigger_counter -= 1
		else: b.trigger_counter = int(list[1])
	else: b.trigger_counter += 2
	if trigger_counter >= commands.size(): b.trigger_counter -= 1
	
	resetTriggers(b)
	getCurrentTriggers(b)

func checkTrigger(b, t_id:String, isNode:bool):
	var t = Spawning.trigger(id+"/"+t_id)
	
	match t.resource_name:
		"TrigCol":
			if t.group_to_collide != "": return (t.group_to_collide in b.get("trig_collider").get_groups())
			elif t.node_collide: return t.node_collide == b.get("trig_collider")
			elif t.on_bounce: return (b.get("bounces", 0) > 0)
			else: return true
		"TrigTime":
			if isNode: return b.trig_timeout(t.time)
			elif b.get("trigger_timeout"): return true
		"TrigPos":
			var arg = b.get("position")
			if t.node_target: return arg.distance_to(t.node_target.global_position) < t.distance
			match t.on_axis:
				t.AXIS.X: return abs(arg.x-t.pos.x) < t.distance
				t.AXIS.Y: return abs(arg.y-t.pos.y) < t.distance
				t.AXIS.BOTH: return arg.distance_to(t.pos) < t.distance
		"TrigSig": return b.get("trig_signal") == t.sig
	
	return false
