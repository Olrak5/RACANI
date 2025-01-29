extends Node

class_name Main

signal http_completed

var field_size = 8
var field
var hitboxes_container
var selected_cell
var hitboxes: Array[Array]

var selected_entity: Entity

var unknown = Color("dark gray", 0.20)
var not_selected = Color("dark gray", 0.06)
var selected = Color("yellow", 0.3)
var movable = Color("blue", 0.3)
var attackable = Color("red", 0.3)

var testing = true

var internet_enabled = true

var url: String = "http://127.0.0.1:8000" + "/api/v1"

var json: JSON

var http_request: HTTPRequest

var result
var response_code
var headers
var body

var availible_moves: Array[Array]

var positions: Array[Array]

var scale: Vector3

var game: Game

var TEAMS_NEUTRAL_ID = "neutral"

var resource_label: Node

var unit_label: Node

var team_label: Node

var map_name: String = "example_full" #"example"

var team_names: Array[String] = ["Team 1", "Team 2"]

var buildingCallable = Callable(self, "buildingSelected")

var visible_map_sectors

# var active_team_id: String

enum GameStates {
	BEFORE_START,
	IN_PROGRESS,
	FINISHED,
}

class Map:
	var sectors: Array 
	var entities: Dictionary 
	var influence: Array 
	
	func _init():
		sectors = []
		entities = {}
		influence = []
	
	func setFromJSON(data):
		sectors = []
		for i in len(data["sectors"]):
			var temp = []
			for j in len(data["sectors"]):
				temp.append([])
			sectors.append(temp)
		for i in len(data["sectors"]):
			for j in len(data["sectors"]):
				sectors[i][j] = data["sectors"][j][i]
			 
		#sectors = data["sectors"]
		for key in data["entities"].keys():
			var entity = Entity.new()
			entity.setFromJSON(data["entities"][key])
			entities[key] = entity
			#print()
			#print(data["entities"].keys())
			#print()
			#print(entities[key])
			#print(data["entities"][key])
			#print()
		#entities = data["entities"]
		#print(data["entities"])
		#print()
		#print("ents")
		#print(entities)
		influence = data["influence"]
		#print(influence)

class Game:
	var id: String
	var map: Map
	var teams: Dictionary 
	var state: GameStates
	var activeTeamId: String
	var winningTeamId: String
	
	func _init():
		var TEAMS_NEUTRAL_ID = "neutral"
		activeTeamId = TEAMS_NEUTRAL_ID
		winningTeamId = TEAMS_NEUTRAL_ID
		map = Map.new()
		teams = {}
		state = GameStates.BEFORE_START
		
	func setFromJSON(data):
		id = data["id"]
		map.setFromJSON(data["map"])
		teams = {}
		for i in data["teams"].keys():
			var team = Team.new()
			team.setFromJSON(data["teams"][i])
			teams[i] = team
		state = GameStates.get(data["state"].to_upper())
		activeTeamId = data["activeTeamId"]
		winningTeamId = data["winningTeamId"]
		
		if false:
			map = Map.new()
			map.setFromJSON(JSON.parse_string('{"sectors":[[[{"id":"1c83c71f-f051-40ba-b591-183e040addd6","position":{"x":0,"y":0},"teamId":"34214631246321463123","type":"Capital","namespace":"buildings"}, {"id":"78e34539-dc79-41c0-99c1-591294f6a9bc","position":{"x":0,"y":0},"teamId":"4532164312","type":"Worker","namespace":"units","health":5,"armor":0,"damage":0,"movementRange":1,"attackRange":0}],[],[],[{"id":"58eb376a-ed8b-4084-be05-0c4c646e23c3","position":{"x":0,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"eda37701-ab8c-4ffc-8365-4952db04768b","position":{"x":1,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"eb19e8af-97c9-447c-8c20-ad44c578c254","position":{"x":2,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"9f5979f8-b27f-41dd-b2fe-4e4ea20bdf3b","position":{"x":3,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"b84c0038-cfd5-4f89-80b7-cf8135cc9a2b","position":{"x":4,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"af948946-2b96-4aca-91a9-867388fe1164","position":{"x":5,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"1d2ce34c-a969-41e1-a284-d9b6b439a598","position":{"x":6,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[],[],[],[],[{"id":"9b7ac6e1-0b0a-407e-9bb5-42ebf3773fcf","position":{"x":7,"y":7},"teamId":"91463216425320541230","type":"Capital","namespace":"buildings"}]]],"entities":{"1c83c71f-f051-40ba-b591-183e040addd6":{"id":"1c83c71f-f051-40ba-b591-183e040addd6","position":{"x":0,"y":0},"teamId":"34214631246321463123","type":"Capital","namespace":"buildings"},"9b7ac6e1-0b0a-407e-9bb5-42ebf3773fcf":{"id":"9b7ac6e1-0b0a-407e-9bb5-42ebf3773fcf","position":{"x":7,"y":7},"teamId":"91463216425320541230","type":"Capital","namespace":"buildings"},"58eb376a-ed8b-4084-be05-0c4c646e23c3":{"id":"58eb376a-ed8b-4084-be05-0c4c646e23c3","position":{"x":0,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"eda37701-ab8c-4ffc-8365-4952db04768b":{"id":"eda37701-ab8c-4ffc-8365-4952db04768b","position":{"x":1,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"eb19e8af-97c9-447c-8c20-ad44c578c254":{"id":"eb19e8af-97c9-447c-8c20-ad44c578c254","position":{"x":2,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"9f5979f8-b27f-41dd-b2fe-4e4ea20bdf3b":{"id":"9f5979f8-b27f-41dd-b2fe-4e4ea20bdf3b","position":{"x":3,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"b84c0038-cfd5-4f89-80b7-cf8135cc9a2b":{"id":"b84c0038-cfd5-4f89-80b7-cf8135cc9a2b","position":{"x":4,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"af948946-2b96-4aca-91a9-867388fe1164":{"id":"af948946-2b96-4aca-91a9-867388fe1164","position":{"x":5,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"1d2ce34c-a969-41e1-a284-d9b6b439a598":{"id":"1d2ce34c-a969-41e1-a284-d9b6b439a598","position":{"x":6,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}},"influence":[["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"]]}'))
		
		#print(id)
		#print(map)
		#print(teams)
		#print(state)
		#print(activeTeamId)
		#print(winningTeamId)
		

class Resources:
	var food: int = 0
	var wood: int = 0
	var minerals: int = 0
	
	func _init():
		food = 0
		wood = 0
		minerals = 0
	
	func setFromJSON(data):
		food = data["food"]
		wood = data["wood"]
		minerals = data["minerals"]
		

class Team:
	var id: String
	var name: String
	var visible_area: Array[Vector2i]
	var resources: Resources
	var max_population
	var is_defeated
	
	func _init():
		visible_area = []
		resources = Resources.new()
	
	func setFromJSON(data):
		id = data["id"]
		name = data["name"]
		#print(data["visibleArea"])
		for value in data["visibleArea"]:
			visible_area.append(Vector2i(value["x"], value["y"]))
		#visible_area = data["visibleArea"]
		resources.setFromJSON(data["resources"])
		max_population = data["maxPopulation"]
		is_defeated = data["isDefeated"]
	
class Entity:
	var id: String
	var position: Vector2i
	var teamId: String
	var type: String
	var ns: String
	var unit: Node = null
	
	func _init():
		unit = null
	
	func setFromJSON(data):
		id = data["id"]
		position = Vector2i(data["position"]["x"], data["position"]["y"])
		teamId = data["teamId"]
		type = data["type"]
		ns = data["namespace"]
		#print(id)
		#print(ns)
	
var unitInfo = [
	 'units/AdvancedSoldier', "res://assets/VO-entiteti/soldier/fighter.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.5,0.5,0.5),
	 'units/Soldier', "res://assets/VO-entiteti/soldier/fighter.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.5,0.5,0.5),
	 'units/Worker', "res://assets/VO-entiteti/worker/scene.gltf", Vector3(0,0,0), Vector3(0,0.05,0), Vector3(0.4,0.4,0.4),
	 'units/Tank', "res://assets/VO-entiteti/tank/tank.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.005,0.005,0.005),
	 'units/Cavalry', "res://assets/VO-entiteti/cavalry/scene.gltf", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.3,0.3,0.3),
	 'units/AdvancedRanged', "res://assets/VO-entiteti/ranged/ranged.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.33,0.33,0.33),
	 'units/Scout', "res://assets/VO-entiteti/scout/scene.gltf", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.015,0.015,0.015),
	 'units/AdvancedTank', "res://assets/VO-entiteti/tank/tank.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.005,0.005,0.005),
	 'units/Ranged', "res://assets/VO-entiteti/ranged/ranged.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.33,0.33,0.33),
	 'buildings/UnitUpgrader', "res://assets/VO-entiteti/unit_upgrader/scene.gltf", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.01,0.01,0.01),
	 'buildings/Capital', "res://assets/VO-entiteti/main_city/scene.gltf", Vector3(0,0.12,0), Vector3(0,0,0), Vector3(0.1,0.1,0.1),
	 'buildings/Barracks', "res://assets/VO-entiteti/barracks/scene.gltf", Vector3(0.375,0,-0.3), Vector3(0,0,0), Vector3(0.66,0.66,0.66),
	 'buildings/unit_generators/WorkerGenerator', "res://assets/VO-entiteti/worker_generator/builder_hut.glb", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.15,0.15,0.15),
	 'buildings/unit_generators/SoldierGenerator', "res://assets/VO-entiteti/soldier_generator/scene.gltf", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.003,0.003,0.003),
	 'buildings/unit_generators/TankGenerator', "res://assets/VO-entiteti/tank_generator/scene.gltf", Vector3(0,0.1,0), Vector3(0,0,0), Vector3(1.0,1.0,1.0),
	 'buildings/unit_generators/RangedGenerator', "res://assets/VO-entiteti/ranged_generator/scene.gltf", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.005,0.005,0.005),
	 'buildings/unit_generators/ScoutGenerator', "res://assets/VO-entiteti/scout_generator/scene.gltf", Vector3(0,0,0), Vector3(0,0,0), Vector3(0.01,0.01,0.01),
	 'buildings/resource_collectors/Farm', "res://assets/VO-entiteti/farm/scene.gltf", Vector3(0,0.1,0), Vector3(0,0,0), Vector3(0.04,0.04,0.04),
	 'buildings/resource_collectors/Sawmill', "res://assets/VO-entiteti/sawmill/scene.gltf", Vector3(0,0.05,0), Vector3(0,0,0), Vector3(0.02,0.02,0.02),
	 'buildings/resource_collectors/Miner', "res://assets/VO-entiteti/mine/scene.gltf", Vector3(-0.027,0.1,-0.021), Vector3(0,0,0), Vector3(0.075,0.075,0.075),
	 'obstacles/Mountain', "res://assets/VO-entiteti/mountain/everest.gltf", Vector3(0,0.1,0), Vector3(0,0,0), Vector3(0.3,0.3,0.3),
	 'resources/Food', "res://assets/VO-entiteti/food/green_field.glb", Vector3(0,0.05,0), Vector3(0,0,0), Vector3(0.05,0.05,0.05),
	 'resources/Wood', "res://assets/VO-entiteti/wood/scene.gltf", Vector3(0,0.3,0), Vector3(0,0,0), Vector3(0.9,0.9,0.9),
	 'resources/Mineral', "res://assets/VO-entiteti/mineral/scene.gltf", Vector3(0, -0.444, 0), Vector3(0,0,0), Vector3(1, 1, 1),
	]
	
var unit_data_count 
	
func unitsAllInfo():
	var types = []
	var paths = []
	var poss = []
	var rots = []
	var scales = []
	for i in range(len(unitInfo)):
		if i%5 ==0:
			types.append(unitInfo[i])
		elif i%5 ==1:
			paths.append(unitInfo[i])
		elif i%5 ==2:
			poss.append(unitInfo[i])
		elif i%5 ==3:
			rots.append(unitInfo[i])
		else:
			scales.append(unitInfo[i])
			
	return {"types": types, "paths": paths, "positions": poss, "rotations": rots, "scales": scales}

var units = {}

var unit_preloads = {
	'units/AdvancedSoldier': AdvancedSoldier_preload,
	'units/Soldier': Soldier_preload,
	'units/Worker': Worker_preload,
	'units/Tank': Tank_preload,
	'units/Cavalry': Cavalry_preload,
	'units/AdvancedRanged': AdvancedRanged_preload,
	'units/Scout': Scout_preload,
	'units/AdvancedTank': AdvancedTank_preload,
	'units/Ranged': Ranged_preload,
	'buildings/UnitUpgrader': UnitUpgrader_preload,
	'buildings/Capital': Capital_preload,
	'buildings/Barracks': Barracks_preload,
	'buildings/unit_generators/WorkerGenerator': WorkerGenerator_preload,
	'buildings/unit_generators/SoldierGenerator': SoldierGenerator_preload,
	'buildings/unit_generators/TankGenerator': TankGenerator_preload,
	'buildings/unit_generators/RangedGenerator': RangedGenerator_preload,
	'buildings/unit_generators/ScoutGenerator': ScoutGenerator_preload,
	'buildings/resource_collectors/Farm': Farm_preload,
	'buildings/resource_collectors/Sawmill': Sawmill_preload,
	'buildings/resource_collectors/Miner': Miner_preload,
	'obstacles/Mountain': Mountain_preload,
	'resources/Food': Food_preload,
	'resources/Wood': Wood_preload,
	'resources/Mineral': Mineral_preload
}

var AdvancedSoldier_preload
var Soldier_preload
var Worker_preload
var Tank_preload
var Cavalry_preload
var AdvancedRanged_preload
var Scout_preload
var AdvancedTank_preload
var Ranged_preload
var UnitUpgrader_preload
var Capital_preload
var Barracks_preload
var WorkerGenerator_preload
var SoldierGenerator_preload
var TankGenerator_preload
var RangedGenerator_preload
var ScoutGenerator_preload
var Farm_preload
var Sawmill_preload
var Miner_preload
var Mountain_preload
var Food_preload
var Wood_preload
var Mineral_preload

var basic_unit_preload

func prepareUnits():
	#print("prepareUnits")
	for type in unitsAllInfo()["types"]:
		units[type] = {"free": [], "used": []}
		
func getFreeUnit(nstype: String) -> Node:
	var dict = units[nstype]
	if dict["free"].size() == 0:
		var unit = makeNewUnit(nstype)
		dict["used"].append(unit)
		return unit
	else:
		#print("using old unit " + nstype)
		var unit = dict["free"].pop_back()
		dict["used"].append(unit)
		unit.set_visible(true)
		return unit

#func freeUnit(entity):
	#var nstype = entity.ns + "/" + entity.type
	#var dict = units[nstype]
	#var pos = dict["used"].find(entity.unit)
	#
	#print("used" + str(dict["used"]))
	#print(entity.unit)
	##push_error("trying to free " + entity.unit.name)
	#
	#if pos == -1:
		#return
	#var unit = dict["used"][pos]
	#unit.set_visible(false)
	#dict["used"].remove_at[pos]
	#dict["free"].append(unit)
	#
	#print("freed " + unit.id)
	
func makeNewUnit(nstype) -> Node:
	#print("making new unit " + nstype)
	
	field = get_node("Field")
	var entities = field.get_node("Entities")
	
	var allInfo = unitsAllInfo()
	
	var pos = allInfo["types"].find(nstype)
	
	var instance
	
	if allInfo["paths"][pos] == null:
		instance = basic_unit_preload.instantiate()
	else:
		var gltf_document_load = GLTFDocument.new()
		var gltf_state_load = GLTFState.new()
		var error = gltf_document_load.append_from_file(
				allInfo["paths"][pos], gltf_state_load)
		if error == OK:
			instance = gltf_document_load.generate_scene(gltf_state_load)
			instance.position = allInfo["positions"][pos]
			instance.rotation = allInfo["rotations"][pos]
			instance.scale = allInfo["scales"][pos]
			instance.name = nstype + " " + str(len(units[nstype]["free"])+len(units[nstype]["used"]))
		else:
			push_error("Couldn't load glTF scene (error code: %s)." % error_string(error))
	
	#print(instance.get_children().get_children())
	#instance.input_ray_pickable = false
	
	entities.add_child(instance)
	return instance
	
func freeAllUnitsFromEntities():
	#for nstype in unitsAllInfo()["types"]:
		#for entity in units[nstype]["used"]:
			#freeUnit(entity)
			
	#for key in entities.keys():
		#var entity = entities[key]
		#print(key)
		#freeUnit(entity)
		
	for nstype in unitsAllInfo()["types"]:
		#print(nstype)
		print(units[nstype]["used"])
		for unit in units[nstype]["used"]:
			#unit.set_visible(false)
			print(unit.name)
		for i in len(units[nstype]["used"]):
			#print("clear clear " + str(i))
			units[nstype]["used"][i].set_visible(false)
			units[nstype]["free"].append(units[nstype]["used"][i])
			
			#print(units[nstype]["free"])
		#print("pre")
		#print(units[nstype]["free"])
		
		units[nstype]["used"].clear()
		#print("post")
		print(units[nstype]["free"])
		print(units[nstype]["used"])
		
	#for nstype in unitsAllInfo()["types"]:
		#for i in len(units[nstype]["free"]):
			#print("clear huh " + str(i))
		
	#var nstype = entity.ns + "/" + entity.type
	#var dict = units[nstype]
	#var pos = dict["used"].find(entity.unit)
	#
	#print("used" + str(dict["used"]))
	#print(entity.unit)
	##push_error("trying to free " + entity.unit.name)
	#
	#if pos == -1:
		#return
	#var unit = dict["used"][pos]
	#unit.set_visible(false)
	#dict["used"].remove_at[pos]
	#dict["free"].append(unit)
	#
	#print("freed " + unit.id)
	
func showUnits(entities):
	for key in entities.keys():
		var entity = entities[key]
		#print(entity)
		var allInfo = unitsAllInfo()
		var nstype = entity.ns + "/" + entity.type
		var pos = allInfo["types"].find(nstype)
		entity.unit = getFreeUnit(nstype)
		entity.unit.position.x = positions[entity.position.x][entity.position.y].z + allInfo["positions"][pos].x
		#entity.unit.position.y = positions[entity.position.x][entity.position.y].y
		entity.unit.position.z = positions[entity.position.x][entity.position.y].x + allInfo["positions"][pos].z
		#if entity.ns == "units":
			#entity.unit.position.x = positions[entity.position.x][entity.position.y].z
			##entity.unit.position.y = positions[entity.position.x][entity.position.y].y
			#entity.unit.position.z = positions[entity.position.x][entity.position.y].x
		#else:
			#entity.unit.position.x = positions[entity.position.x][entity.position.y].x
			##entity.unit.position.y = positions[entity.position.x][entity.position.y].y
			#entity.unit.position.z = positions[entity.position.x][entity.position.y].z
		
var button_text = [
	"Unit Upgrader",
	"Barracks",
	"Worker Generator",
	"Soldier Generator",
	"Tank Generator",
	"Ranged Generator",
	"Scout Generator",
	"Farm",
	"Sawmill",
	"Miner",
]

var building_ns = [
	'buildings',
	'buildings',
	'buildings/unit_generators',
	'buildings/unit_generators',
	'buildings/unit_generators',
	'buildings/unit_generators',
	'buildings/unit_generators',
	'buildings/resource_collectors',
	'buildings/resource_collectors',
	'buildings/resource_collectors',
]

var building_types = [
	"UnitUpgrader",
	"Barracks",
	"WorkerGenerator",
	"SoldierGenerator",
	"TankGenerator",
	"RangedGenerator",
	"ScoutGenerator",
	"Farm",
	"Sawmill",
	"Miner",
]

func getSectorsAllEntities(sectors):
	var entities = {}
	for i in range(field_size):
		for j in range(field_size):
			# var sector = game.map.sectors[i][j]
			var sector = sectors[i][j] #SWAP
			#print(sector)
			if sector != null:
				var resource_id: String = ""
				var collector_present = false
				for data in sector:
					var entity = Entity.new()
					entity.setFromJSON(data)
					if entity.ns == "resources":
						resource_id = entity.id
					if entity.ns == "buildings/resource_collectors":
						collector_present = true
					entities[entity["id"]] = entity
				if collector_present == true && resource_id != "":
					entities.erase(resource_id)
	return entities

# func updateMap(data):
#     clearMap()
#     updateGameSectors(data)

func showUnitsFromData(data):
	showUnits(getSectorsAllEntities(data))

func clearMap():
	#print("clearing " + str(game.map.entities))
	#freeAllUnitsFromEntities(game.map.entities)
	#print("clearing all")
	freeAllUnitsFromEntities()

# func updateGame(data):
#     game = game.setFromJSON(data)
	
# func updateGameSectors(data):
#     game.map.sectors = data

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
		
	json = JSON.new()
	
	resource_label = get_node("UserInterface/ResourceLabel")
	
	team_label = get_node("UserInterface/TeamLabel")
	
	unit_label = get_node("UserInterface/UnitLabel")
	
	basic_unit_preload = preload("res://unit.tscn")
	
	var building_select = get_node("UserInterface/BuildingSelect")
	var buttons = building_select.get_children()
	
	for i in range(len(buttons)):
		if i != 0:
			buttons[i].text = button_text[i-1] 
			buttons[i].pressed.connect(self.buildingSelected.bind(building_types[i-1]))
			#buttons[i].connect("pressed", await buildingSelected(buttons[i].text))
			#self.buildingCallable.connect(buttons[i].pressed)
		
	building_select.set_visible(false)
	
	field = get_node("Field")
	var hitbox_preload = preload("res://hitbox.tscn")
	hitboxes_container = field.get_node("Hitboxes")
	#print(hitboxes)
	#var instance = hitbox.instantiate()
	#hitboxes.add_child(instance)
	for i in range(field_size):
		hitboxes.append([]) 
		for j in range(field_size):
			hitboxes[i].append(null)
			
	for i in range(field_size):
		positions.append([]) 
		for j in range(field_size):
			positions[i].append(Vector3(-4+4.0/field_size+2*i*(4.0/field_size),0.5,
					-4+4.0/field_size+2*j*(4.0/field_size)))
	
	var scale_xyz = 8.0/field_size
	scale = Vector3(scale_xyz,scale_xyz,scale_xyz)
	
	for i in range(field_size):
			availible_moves.append([]) 
			for j in range(field_size):
				availible_moves[i].append(null)
	
	for i in range(field_size):
		for j in range(field_size):
			var instance = hitbox_preload.instantiate()
			instance.name = "hitbox_" + str(i) + "_" + str(j)
			#instance.position = Vector3(-4 + 4.0/fieldSize + 7/(fieldSize-1)*i, \
				#0.5, -4 + 4.0/fieldSize + 7/(fieldSize-1)*j)
			instance.position = positions[i][j]
			instance.scale = scale
			#print(instance.position)
			#print((fieldSize-1))
			#print((fieldSize-1)/2)
			instance.location = Vector2i(i, j)
			
			
			var material = instance.get_node("MeshInstance3D").get_active_material(0)
			material = material.duplicate()
			material.albedo_color = not_selected
			instance.get_node("MeshInstance3D").set_surface_override_material(0, material)
			
			
			hitboxes_container.add_child(instance)
			hitboxes[i][j] = instance
			#print("test")
		
	#print(hitboxes.get_children())
	
	#for hitbox in hitboxes.get_children():
		#hitbox.input_event.connect(selectedCell)
		
	clearActions()
	
	prepareUnits()

	await createGame(map_name)

	await createTeam(game.id, team_names[0])

	await createTeam(game.id, team_names[1])
	
	await start_game(game.id)
	#
	#print(json.data.keys())

	await get_game_info(game.id)

	# active_team_id = game["activeTeamId"]

	# show map and let player do moves and end turn

	await updateMap()
	
	# await getVisibleMap()
	
	# if internet_enabled:
	#     #print(json.data.keys())
		
	#     var map_data = json.data["sectors"]
		
	#     updateMap(map_data)
	
	# else:
	#     updateMap(game.map.sectors)
	
	#var gltf_document_load = GLTFDocument.new()
	#var gltf_state_load = GLTFState.new()
	#var error = gltf_document_load.append_from_file(
			#"res://assets/VO-entiteti/worker_generator/worker_generator.glb", gltf_state_load)
	#if error == OK:
		#var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
		#add_child(gltf_scene_root_node)
	#else:
		#push_error("Couldn't load glTF scene (error code: %s)." % error_string(error))
		
	updateResources()
	updateTeamName()

func updateMap():
	#print("updating map")
	
	updateUnitInfo(null)
	
	clearMap()
	
	#print("cleared map")

	await getVisibleMap()

	showUnitsFromData(visible_map_sectors)
		
	# updateMap(visible_map_sectors)
	
	#TODO add fog of war coloring
	
	colorVisibleSectors(visible_map_sectors)
	
func colorVisibleSectors(sectors):
	for i in range(field_size):
		for j in range(field_size):
			var cell = hitboxes[i][j]
			if sectors[j][i] == null:
				colorObject(cell, unknown)
			#else if sectors[i][j] == []:
				#colorObject(cell, color)
			else:
				colorObject(cell, not_selected)

func colorObject(object, color):
	var material = object.get_node("MeshInstance3D").get_active_material(0)
	material = material.duplicate()
	material.albedo_color = color
	object.get_node("MeshInstance3D").set_surface_override_material(0, material)
	
func getSelectedEntity(location: Vector2i) -> Entity:
	var top_unit = null
	
	var swapped_location = Vector2i(location.y, location.x)
	
	#print(game.map.sectors)
	#print()
	#print(game.map.sectors[location.x][location.y])
	
	#if ! game.teams[game.activeTeamId].visible_area.has(swapped_location): # neprijateljski unit kaze da nema nista
		#print("not visible??")
		#return null
	
	for unit in game.map.sectors[swapped_location.x][swapped_location.y]:
		if top_unit == null:
			top_unit = unit
		elif top_unit["namespace"] != "units":
			top_unit = unit
			
	if top_unit == null || top_unit["namespace"] != "units":
		return null
		
	var sector_entitites = getSectorsAllEntities(game.map.sectors)
	
	return sector_entitites[top_unit["id"]]
	
func selectedCell(location: Vector2i) -> void:
	if (selected_cell != null && selected_cell.location == location):
		return
	
	if (availible_moves[location.x][location.y] != null):
		if internet_enabled:
			clearActions()
			await move(location)
			# var map_data = json.data["sectors"]
		
			# updateMap(map_data)
			selected_cell = null
		return

	# print(selected_cell == null)
	# if (selected_cell != null):
	#     print(selected_cell.location != location)

	if (selected_cell == null || selected_cell.location != location):
		clearActions()
		#cancelAction()
		
	selected_cell = hitboxes[location.x][location.y]
	colorObject(selected_cell, selected)
	#print(location)
	
	selected_entity = getSelectedEntity(location)
	
	print(selected_entity)
	
	
	
	var top_unit = null
	
	print(visible_map_sectors)
	
	var swapped_location = Vector2i(location.y, location.x)
	
	if visible_map_sectors[swapped_location.x][swapped_location.y] != null:
		print("top_unit all = " + str(visible_map_sectors[swapped_location.x][swapped_location.y]))
		for unit in visible_map_sectors[swapped_location.x][swapped_location.y]:				
			if top_unit == null:
				top_unit = unit
			elif top_unit["namespace"] != "units":
				top_unit = unit
				
			if top_unit!=null:
				print("top_unit=" + top_unit["namespace"])
	
	updateUnitInfo(top_unit)
	
	if selected_entity == null:
		return
	
	if internet_enabled:
		var send_name = "selectedCell1"
		var send_endpoint = "/game/"+ game.id +"/team/" + game.activeTeamId \
			 + "/unit/" + selected_entity.id + "/build/available-buildings"
		var send_headers = []
		var send_method = HTTPClient.METHOD_GET
		var send_data = JSON.stringify({})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

		# var name = "selectedCell"
		
		# var error = send_request("/game/"+ game.id +"/team/" + game.activeTeamId
		#      + "/end-unit/" + selected_entity.id + "/build/available-buildings", 
		#     [], HTTPClient.METHOD_POST, JSON.stringify({}))
		
		# if error != OK:
		#     push_error(name + " sendRequest available")
		
		# await http_completed
		
		# passJson(name, body)

		print("availible print" + str(json.data))
		var available_buldings = json.data["availableBuildings"]
		
		var building_select = get_node("UserInterface/BuildingSelect")
		
		if available_buldings != null:
			building_select.set_visible(true)
		
			var buttons = building_select.get_children()
			
			for i in range(len(buttons)):
				if i != 0:
					buttons[i].set_visible(false)
			
			for ns_type in available_buldings:
				var pos = building_types.find(ns_type[1])
				if pos != -1:
					buttons[pos+1].set_visible(true)


		send_name = "selectedCell2"
		send_endpoint = "/game/"+ game.id +"/team/" + game.activeTeamId \
			 + "/unit/" + selected_entity.id + "/move/reachable-sectors"
		send_headers = []
		send_method = HTTPClient.METHOD_GET
		send_data = JSON.stringify({})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)
			
		
		# error = send_request("/game/"+ game.id +"/team/" + game.activeTeamId
		#      + "/end-unit/" + selected_entity.id + "/move/reachable-sectors", 
		#     [], HTTPClient.METHOD_POST, JSON.stringify({}))
		
		# if error != OK:
		#     push_error(name + " sendRequest available")
		
		# await http_completed
		
		# passJson(name, body)


		
		var reachable_sectors = json.data["sectors"]
		
		setAvailableMoves(reachable_sectors)
		
		colorAvailableMoves(movable)
		
	else:
		var available_buldings = [["buildings", "UnitUpgrader"], ["buildings", "Capital"], ["buildings", "Barracks"], ["buildings/unit_generators", "WorkerGenerator"], ["buildings/unit_generators", "SoldierGenerator"], ["buildings/unit_generators", "TankGenerator"], ["buildings/unit_generators", "RangedGenerator"], ["buildings/unit_generators", "ScoutGenerator"]]
		
		var building_select = get_node("UserInterface/BuildingSelect")
		
		if available_buldings != []:
			building_select.set_visible(true)
		
		var buttons = building_select.get_children()
		
		for i in range(len(buttons)):
			if i != 0:
				buttons[i].set_visible(false)
		
		for ns_type in available_buldings:
			var pos = building_types.find(ns_type[1])
			buttons[pos+1].set_visible(true)
		
		var reachable_sectors = [
			{"x":0, "y":1},
			{"x":1, "y":0},
			]
			
		setAvailableMoves(reachable_sectors)
			
		colorAvailableMoves(movable)
	
		
	
	# work with results -> result, response_code, headers, body

func setAvailableMoves(reachable_sectors):
	if reachable_sectors == null:
		return
	for pos in reachable_sectors:
		availible_moves[pos["y"]][pos["x"]] = 1
		
func colorAvailableMoves(color):
	for i in range(field_size):
		for j in range(field_size):
			if availible_moves[i][j] != null:
				var availible_cell = hitboxes[i][j]
				colorObject(availible_cell, color)
	for i in range(field_size):
		for j in range(field_size):
			if availible_moves[i][j] != null:
				var availible_cell = hitboxes[j][i]
				#print(1)
				#print(visible_map_sectors[i][j] != null)
				#if (visible_map_sectors[i][j] != null):
					#print(2)
					#if (len(visible_map_sectors[i][j]) <= 1):
						#print(visible_map_sectors[i])
						#print(visible_map_sectors[i][j])
					#print(len(visible_map_sectors[i][j]) > 1)
				#if (visible_map_sectors[i][j] != null && len(visible_map_sectors[i][j]) > 1):
					#print(3)
					#print(visible_map_sectors[i][j][0].teamId != game.activeTeamId)
				var to_attack: bool = false
				if visible_map_sectors[i][j] != null:
					for entity in visible_map_sectors[i][j]:
						# var other_team_id: String
						if entity.teamId != game.activeTeamId and entity.namespace == "units":
							to_attack = true
				# if visible_map_sectors[i][j] != null && len(visible_map_sectors[i][j]) > 1 && visible_map_sectors[i][j][0].teamId != game.activeTeamId:
				if to_attack:
					colorObject(availible_cell, attackable)




func clearActions():			
	var building_select = get_node("UserInterface/BuildingSelect")
	var buttons = building_select.get_children()
	
	building_select.set_visible(false)
	
	for i in range(len(buttons)):
		if i != 0:
			buttons[i].set_visible(false)
			
	#colorAvailableMoves(not_selected)
	
	if visible_map_sectors != null:
		colorVisibleSectors(visible_map_sectors)
	
	#if (selected_cell != null):
		#colorObject(selected_cell, not_selected)
		
	
	availible_moves = []
	for i in range(field_size):
		availible_moves.append([]) 
		for j in range(field_size):
			availible_moves[i].append(null)
		
	#print(selected_cell.location)
	
# TODO
func move(location):
	if internet_enabled:
		var send_name = "move"
		var send_endpoint = "/game/"+ game.id +"/team/" + game.activeTeamId \
			 + "/unit/" + selected_entity.id + "/move"
		var send_headers = []
		var send_method = HTTPClient.METHOD_POST
		var send_data = JSON.stringify({"targetPosition": {"x": location.y, "y": location.x}})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

	else:
		pass

	await get_game_info(game.id)
	await updateMap()
	
	#print(game.map.sectors[location.x][location.y])



		# var name = "move"
		# var error = send_request("/game/"+ game.id +"/team/" + game.activeTeamId
		#      + "/visible-map" , [], HTTPClient.METHOD_POST, JSON.stringify({}))
		
		# if error != OK:
		#     push_error(name + " move")
		
		# await http_completed
		
		# passJson(name, body)
	
	
	
func passJson(where):
	print("recieved from " + where)
	#print(body)
	var error = json.parse(body.get_string_from_utf8())

	print(json.data)
	
	if error != OK:
		push_error(where + " json")
		#push_error(error)
		push_error("JSON Parse Error: " + json.get_error_message() + " in " + body.get_string_from_utf8() + 
			" at line " + str(json.get_error_line()))

func getVisibleMap():
	if internet_enabled:
		var send_name = "getVisibleMap"
		var send_endpoint = "/game/"+ game.id +"/team/" + game.activeTeamId + "/visible-map"
		var send_headers = []
		var send_method = HTTPClient.METHOD_GET
		var send_data = JSON.stringify({})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

		# var name = "getVisibleMap"
		# var error = send_request("/game/"+ game.id +"/team/" + game.activeTeamId
		#      + "/visible-map" , [], HTTPClient.METHOD_POST, JSON.stringify({}))
		
		# if error != OK:
		#     push_error(name + " getVisibleMap")
		
		# await http_completed
		
		# passJson(name, body)
		
		print(json.data["sectors"])
		visible_map_sectors = []
		for i in len(json.data["sectors"]):
			var temp = []
			for j in len(json.data["sectors"]):
				temp.append([])
			visible_map_sectors.append(temp)
		for i in len(json.data["sectors"]):
			for j in len(json.data["sectors"]):
				visible_map_sectors[i][j] = json.data["sectors"][j][i]
				
		print("visible map" + str(visible_map_sectors))
		#visible_map_sectors = json.data["sectors"]
	else:
		visible_map_sectors = JSON.parse_string('{"sectors":[[[{"id":"1c83c71f-f051-40ba-b591-183e040addd6","position":{"x":0,"y":0},"teamId":"34214631246321463123","type":"Capital","namespace":"buildings"}, {"id":"78e34539-dc79-41c0-99c1-591294f6a9bc","position":{"x":0,"y":0},"teamId":"4532164312","type":"Worker","namespace":"units","health":5,"armor":0,"damage":0,"movementRange":1,"attackRange":0}],[],[],[{"id":"58eb376a-ed8b-4084-be05-0c4c646e23c3","position":{"x":0,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"eda37701-ab8c-4ffc-8365-4952db04768b","position":{"x":1,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"eb19e8af-97c9-447c-8c20-ad44c578c254","position":{"x":2,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"9f5979f8-b27f-41dd-b2fe-4e4ea20bdf3b","position":{"x":3,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"b84c0038-cfd5-4f89-80b7-cf8135cc9a2b","position":{"x":4,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"af948946-2b96-4aca-91a9-867388fe1164","position":{"x":5,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[{"id":"1d2ce34c-a969-41e1-a284-d9b6b439a598","position":{"x":6,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}],[],[],[],[]],[[],[],[],[],[],[],[],[{"id":"9b7ac6e1-0b0a-407e-9bb5-42ebf3773fcf","position":{"x":7,"y":7},"teamId":"91463216425320541230","type":"Capital","namespace":"buildings"}]]],"entities":{"1c83c71f-f051-40ba-b591-183e040addd6":{"id":"1c83c71f-f051-40ba-b591-183e040addd6","position":{"x":0,"y":0},"teamId":"34214631246321463123","type":"Capital","namespace":"buildings"},"9b7ac6e1-0b0a-407e-9bb5-42ebf3773fcf":{"id":"9b7ac6e1-0b0a-407e-9bb5-42ebf3773fcf","position":{"x":7,"y":7},"teamId":"91463216425320541230","type":"Capital","namespace":"buildings"},"58eb376a-ed8b-4084-be05-0c4c646e23c3":{"id":"58eb376a-ed8b-4084-be05-0c4c646e23c3","position":{"x":0,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"eda37701-ab8c-4ffc-8365-4952db04768b":{"id":"eda37701-ab8c-4ffc-8365-4952db04768b","position":{"x":1,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"eb19e8af-97c9-447c-8c20-ad44c578c254":{"id":"eb19e8af-97c9-447c-8c20-ad44c578c254","position":{"x":2,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"9f5979f8-b27f-41dd-b2fe-4e4ea20bdf3b":{"id":"9f5979f8-b27f-41dd-b2fe-4e4ea20bdf3b","position":{"x":3,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"b84c0038-cfd5-4f89-80b7-cf8135cc9a2b":{"id":"b84c0038-cfd5-4f89-80b7-cf8135cc9a2b","position":{"x":4,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"af948946-2b96-4aca-91a9-867388fe1164":{"id":"af948946-2b96-4aca-91a9-867388fe1164","position":{"x":5,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"},"1d2ce34c-a969-41e1-a284-d9b6b439a598":{"id":"1d2ce34c-a969-41e1-a284-d9b6b439a598","position":{"x":6,"y":3},"teamId":"neutral","type":"Mountain","namespace":"obstacles"}},"influence":[["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"],["neutral","neutral","neutral","neutral","neutral","neutral","neutral","neutral"]]}').data["sectors"]

func createTeam(game_id: String, team_name: String):
	if internet_enabled:
		var send_name = "createTeam"
		var send_endpoint = "/game/" + game_id + "/team"
		var send_headers = []
		var send_method = HTTPClient.METHOD_POST
		var send_data = JSON.stringify({"name": team_name})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

	#print(json.data)

	game.teams[json.data["team"]["id"]] = Team.new()
	# game.teams[json.data["team"]["id"]].name = json.data["team"]["name"]

func createGame(send_map_name: String):
	if internet_enabled:
		var send_name = "createGame"
		var send_endpoint = "/game"
		var send_headers = []
		var send_method = HTTPClient.METHOD_POST
		var send_data = JSON.stringify({"mapName": send_map_name})

		# print("waiting for response")
		
		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

		# print("arrived")

#     else:
#         body = '{
#   "game": {
#     "id": "string",
#     "map": {
#       "sectors": [
#         [
#           [
#             {
#               "id": "string",
#               "position": {
#                 "x": 0,
#                 "y": 0
#               },
#               "teamId": "string",
#               "type": "string",
#               "namespace": "string",
#               "additionalProp1": {}
#             }
#           ]
#         ]
#       ],
#       "entities": {
#         "additionalProp1": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         },
#         "additionalProp2": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         },
#         "additionalProp3": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         }
#       },
#       "influence": [
#         [
#           "string"
#         ]
#       ]
#     },
#     "teams": {
#       "additionalProp1": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       },
#       "additionalProp2": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       },
#       "additionalProp3": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       }
#     },
#     "history": {
#       "actions": [],
#       "mapStates": []
#     },
#     "state": "before_start",
#     "activeTeamId": "neutral",
#     "winningTeamId": "neutral"
#   }
# }'

		# passJson(name)

	# print(json.data)
		
	game = Game.new()
	game.id = json.data["game"]["id"]
	# game.setFromJSON(json.data["game"])

func start_game(game_id: String):
	if internet_enabled:
		var send_name = "start_game"
		var send_endpoint = "/game/" + game_id + "/start" 
		var send_headers = []
		var send_method = HTTPClient.METHOD_POST
		var send_data = JSON.stringify({})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

		# var name = "start_game"
		# var error = send_request("/game" , [], HTTPClient.METHOD_POST, JSON.stringify({"mapName": "mapa"}))
		
		# #print(error)
		
		# if error != OK:
		#     push_error(name + " start_game")
		
		# await http_completed
		
		# print(response_code)
		# print(body)
		# print(json.parse(body))
		
		# passJson(name, body)
		
#     else:
#         body = '{
#   "game": {
#     "id": "string",
#     "map": {
#       "sectors": [
#         [
#           [
#             {
#               "id": "string",
#               "position": {
#                 "x": 0,
#                 "y": 0
#               },
#               "teamId": "string",
#               "type": "string",
#               "namespace": "string",
#               "additionalProp1": {}
#             }
#           ]
#         ]
#       ],
#       "entities": {
#         "additionalProp1": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         },
#         "additionalProp2": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         },
#         "additionalProp3": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         }
#       },
#       "influence": [
#         [
#           "string"
#         ]
#       ]
#     },
#     "teams": {
#       "additionalProp1": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       },
#       "additionalProp2": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       },
#       "additionalProp3": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       }
#     },
#     "history": {
#       "actions": [],
#       "mapStates": []
#     },
#     "state": "before_start",
#     "activeTeamId": "neutral",
#     "winningTeamId": "neutral"
#   }
# }'
#         passJson(name)
		
#     game = Game.new()
#     game.setFromJSON(json.data["game"])


func get_game_info(game_id: String):
	if internet_enabled:
		var send_name = "get_game_info"
		var send_endpoint = "/game/" + game_id
		var send_headers = []
		var send_method = HTTPClient.METHOD_GET
		var send_data = JSON.stringify({})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

		# game = Game.new()
#     else:
#         body = '{
#   "game": {
#     "id": "string",
#     "map": {
#       "sectors": [
#         [
#           [
#             {
#               "id": "string",
#               "position": {
#                 "x": 0,
#                 "y": 0
#               },
#               "teamId": "string",
#               "type": "string",
#               "namespace": "string",
#               "additionalProp1": {}
#             }
#           ]
#         ]
#       ],
#       "entities": {
#         "additionalProp1": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         },
#         "additionalProp2": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         },
#         "additionalProp3": {
#           "id": "string",
#           "position": {
#             "x": 0,
#             "y": 0
#           },
#           "teamId": "string",
#           "type": "string",
#           "namespace": "string",
#           "additionalProp1": {}
#         }
#       },
#       "influence": [
#         [
#           "string"
#         ]
#       ]
#     },
#     "teams": {
#       "additionalProp1": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       },
#       "additionalProp2": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       },
#       "additionalProp3": {
#         "id": "string",
#         "name": "string",
#         "visibleArea": [
#           {
#             "x": 0,
#             "y": 0
#           }
#         ],
#         "resources": {
#           "food": 0,
#           "wood": 0,
#           "minerals": 0
#         }
#       }
#     },
#     "history": {
#       "actions": [],
#       "mapStates": []
#     },
#     "state": "before_start",
#     "activeTeamId": "neutral",
#     "winningTeamId": "neutral"
#   }
# }'

	game.setFromJSON(json.data["game"])

func buildingSelected(extra_arg_0: String):
#func buildingSelected(event: InputEvent, extra_arg_0: String) -> void:
	#if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
	print(extra_arg_0)
	var pos = building_types.find(extra_arg_0)
	print(building_types)
	print(pos)
	if internet_enabled:
		var send_name = "buildingSelected"
		var send_endpoint = "/game/"+ game.id +"/team/" + game.activeTeamId + "/unit/" + selected_entity.id + "/build"
		var send_headers = []
		var send_method = HTTPClient.METHOD_POST
		var send_data = JSON.stringify({
				"buildingType": building_types[pos],
				"buildingNamespace": building_ns[pos]
				})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)

	else:
		body = '{"id":"1c83c71f-f051-40ba-b591-183e040addd6","position":{"x":0,"y":0},"teamId":"34214631246321463123","type":"Capital","namespace":"buildings"}'

		# var name = "buildingSelected"
		# var error = send_request("/game/"+ game.id +"/team/" + game.activeTeamId
		#      + "/unit/" + selected_entity.id + "/build" , [], HTTPClient.METHOD_POST, 
		#     JSON.stringify({
		#         "buildingType": building_types[pos],
		#         "buildingNamespace": building_ns[pos]
		#     }))
		
		# if error != OK:
		#     push_error(name + " buildingSelected")
		
		# await http_completed
		passJson(name)
	
	#
	#print("Built " + json.data["building"]["namespace"] + " "  + json.data["building"]["type"])

	clearActions()
	selected_cell = null
	await get_game_info(game.id)
	await updateMap()
	updateResources()
	updateTeamName()
	
func newTurnPressed():
	if internet_enabled:
		var send_name = "newTurnPressed"
		var send_endpoint = "/game/"+ game.id +"/team/" + game.activeTeamId + "/end-turn"
		var send_headers = []
		var send_method = HTTPClient.METHOD_POST
		var send_data = JSON.stringify({})

		await awaitResponse(send_name, send_endpoint, send_headers, send_method, send_data)
	
	#clearMap()
	clearActions()
	selected_cell = null
	await get_game_info(game.id)
	
	if game.state == GameStates.FINISHED:
		#print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
		#get_tree().quit()
		var end_node = preload("res://GameEnd.tscn").instantiate()
		end_node.get_child(0).text = str(game.teams[game.winningTeamId].name) + " WON"
		get_tree().root.add_child(end_node)
		get_tree().root.remove_child(self)
		#get_tree().change_scene_to_file("res://GameEnd.tscn")
		return
	
	await updateMap()
	updateResources()
	updateTeamName()
	
func updateResources():
	#var resources: Resources
	#if resource_label.resources == null:
		#resources = Resources.new()
	#else:
		#resources = resource_label.resources
	#resources.food += 1
	#resources.wood += 1
	#resources.minerals += 1
	
	resource_label.updateResources(game.teams[game.activeTeamId].resources)
	
func updateUnitInfo(unit_info):
	unit_label.updateUnitInfo(unit_info)
	
func updateTeamName():
	team_label.updateTeamName(game.teams[game.activeTeamId].name, game.teams[game.activeTeamId].max_population)
	

func awaitResponse(send_name: String, send_endpoint: String, send_headers: PackedStringArray, send_method: HTTPClient.Method, send_data: String):
	if internet_enabled:
		var error = send_request(send_endpoint, send_headers, send_method, send_data)
		
		if error != OK:
			push_error(send_name + " " + error)
		
		await http_completed
		
		passJson(send_name)
	
# func cancelAction():
#     if (selected_cell != null):
#         colorObject(selected_cell, not_selected)
		
	
#     var resources: Resources
#     if resource_label.resources == null:
#         resources = Resources.new()
#     else:
#         resources = resource_label.resources
	
#     resources.food += 1
#     resources.wood += 1
#     resources.minerals += 1
	
#     resource_label.updateResources(resources)
	
func _input(event: InputEvent) -> void:
	
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
		clearActions()
		updateUnitInfo(null)
		selected_cell = null
		

func send_request(send_endpoint: String, send_headers: PackedStringArray, send_method: HTTPClient.Method, send_data: String):
	var error = http_request.request(url+send_endpoint, send_headers, send_method, send_data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	print("requestted http")    
	print(url+send_endpoint + " " + str(send_headers) + " " + str(send_method) + " " + send_data)
	
	return error
	
func _http_request_completed(_result, _response_code, _headers, _body):
	print("_http_request_completed start")
	
	if _result != HTTPRequest.RESULT_SUCCESS:
		push_error("HTTP request unsuccessful.")
	
	result = _result
	response_code = _response_code
	headers = _headers
	body = _body
	
	#print("body " + str(body))
	
	print("_http_request_completed")
	
	http_completed.emit()
