import logging


LOG_LEVEL = logging.INFO

TEAMS_NEUTRAL_ID = "neutral"
TEAMS_STARTING_POPULATION = 5
TEAMS_STARTING_RESOURCES = [10, 10, 10]  # food, wood, minerals

UNITS_CONFIG = {
    "Worker": {
        "health": 5,
        "armor": 0,
        "damage": 0,
        "movementRange": 1,
        "attackRange": 0,
    },
    "Soldier": {
        "health": 10,
        "armor": 1,
        "damage": 2,
        "movementRange": 2,
        "attackRange": 1
    },
    "AdvancedSoldier": {
        "health": 15,
        "armor": 2,
        "damage": 3,
        "movementRange": 2,
        "attackRange": 1
    },
    "Ranged": {
        "health": 7,
        "armor": 0,
        "damage": 2,
        "movementRange": 1,
        "attackRange": 2
    },
    "AdvancedRanged": {
        "health": 10,
        "armor": 1,
        "damage": 3,
        "movementRange": 1,
        "attackRange": 3
    },
    "Tank": {
        "health": 15,
        "armor": 3,
        "damage": 2,
        "movementRange": 1,
        "attackRange": 1
    },
    "AdvancedTank": {
        "health": 20,
        "armor": 4,
        "damage": 3,
        "movementRange": 1,
        "attackRange": 2
    },
    "Scout": {
        "health": 3,
        "armor": 0,
        "damage": 1,
        "movementRange": 3,
        "attackRange": 1
    },
    "Cavalry": {
        "health": 10,
        "armor": 1,
        "damage": 2,
        "movementRange": 2,
        "attackRange": 1
    },
}

RESOURCE_COLLECTORS_YIELD = {
    "Sawmill": 2,
    "Miner": 2,
    "Farm": 2,
}

BUILDING_COSTS = {  # food, wood, minerals
    "Sawmill": [0, 0, 0],
    "Miner": [0, 0, 0],
    "Farm": [0, 0, 0],
    "UnitUpgrader": [10, 10, 10],
    "Barracks": [10, 10, 10],
    "WorkerGenerator": [10, 10, 10],
    "SoldierGenerator": [10, 10, 10],
    "RangedGenerator": [10, 10, 10],
    "TankGenerator": [10, 10, 10],
    "ScoutGenerator": [10, 10, 10],
    "Capital": [0, 0, 0],
}

BUILDING_INFLUENCE_SIZE = {
    "Sawmill": 1,
    "Miner": 1,
    "Farm": 1,
    "UnitUpgrader": 0,
    "Barracks": 0,
    "WorkerGenerator": 0,
    "SoldierGenerator": 0,
    "RangedGenerator": 0,
    "TankGenerator": 0,
    "ScoutGenerator": 0,
    "Capital": 2,
}

REGISTRY_SEARCH_PATHS = [
    "entities/dynamic", "entities/static", "simulation/actions"
]
REGISTRY_BASE_CLASSES = [
    "entities.entity.ConcreteEntity",
    "simulation.actions.action.ConcreteAction"
]

MAP_DIR = "maps"
