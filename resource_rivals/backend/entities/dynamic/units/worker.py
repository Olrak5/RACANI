from typing import List, Type

from entities.dynamic.buildings.building import Building
from entities.dynamic.buildings.resource_collectors.farm import Farm
from entities.dynamic.buildings.resource_collectors.miner import Miner
from entities.dynamic.buildings.resource_collectors.sawmill import Sawmill
from entities.dynamic.units.unit import Unit
from entities.entity import ConcreteEntity
from entities.static.resources.food import Food
from entities.static.resources.mineral import Mineral
from entities.static.resources.wood import Wood
from simulation.team import Resources


def get_all_other_buildings() -> List[Building]:
    from utils.registry import registry

    found_buildings = []

    for key, module in registry.modules.items():
        if (
                key.startswith("buildings")
                and "resource_collectors" not in key
                and "Capital" not in key
        ):
            found_buildings.append(module)

    return found_buildings


RESOURCE_TO_COLLECTOR_MAPPING = {
    Wood: Sawmill,
    Food: Farm,
    Mineral: Miner,
}


class Worker(Unit, ConcreteEntity):
    def calculate_available_buildings(
            self, game
    ) -> List[List[str]]:  # (namespace, type) tuples
        buildings = self._calculate_available_buildings_by_position(game)
        buildings = self._filter_available_buildings_by_cost(buildings, game)

        return [
            [building.get_namespace(), building.get_type()]
            for building in buildings
        ]

    def build(self, namespace: str, type: str, game) -> Building:
        from utils.registry import registry

        try:
            building_cls = registry.get(type, namespace)
        except ValueError:
            raise ValueError("Building does not exist")

        building_instance = building_cls(  # type: ignore
            position=self.position, teamId=self.teamId,
        )

        buildings = self._calculate_available_buildings_by_position(game)

        if building_cls not in buildings:
            raise ValueError("Building not allowed to be built here")

        current_team = game.teams[self.teamId]

        if current_team.resources.can_afford(
                self._get_building_cost(building_cls)  # type: ignore
        ):
            cost = Resources(
                food=building_instance.get_cost()[0],  # type: ignore
                wood=building_instance.get_cost()[1],  # type: ignore
                minerals=building_instance.get_cost()[2],  # type: ignore
            )

            game.teams[self.teamId].resources.pay(cost)

            game.map.add_entity(building_instance)
            game.map.remove_entity(self)
        else:
            raise ValueError("Not enough resources to build")

        return building_instance  # type: ignore

    def _calculate_available_buildings_by_position(
            self, game
    ) -> List[Type[Building]]:
        resource_buildings = []
        other_buildings = []

        current_sector = game.map.sectors[self.position.y][self.position.x]

        for entity in current_sector:
            if entity.__class__ in RESOURCE_TO_COLLECTOR_MAPPING:
                resource_buildings.append(
                    RESOURCE_TO_COLLECTOR_MAPPING[entity.__class__]
                )

        if (
                game.map.influence[self.position.y][self.position.x]
                == self.teamId
                and len(current_sector) == 1
        ):
            other_buildings = get_all_other_buildings()

        return resource_buildings + other_buildings  # type: ignore

    def _filter_available_buildings_by_cost(
            self, available_buildings: List[Type[Building]], game
    ) -> List[Type[Building]]:
        current_team = game.teams[self.teamId]
        filtered_buildings = []

        for building in available_buildings:
            if current_team.resources.can_afford(
                    self._get_building_cost(building)
            ):
                filtered_buildings.append(building)

        return filtered_buildings

    def _get_building_cost(
            self, building: Type[Building],
    ) -> Resources:
        building_instance = building(
            position=self.position, teamId=self.teamId
        )

        return Resources(
            food=building_instance.get_cost()[0],  # type: ignore
            wood=building_instance.get_cost()[1],  # type: ignore
            minerals=building_instance.get_cost()[2],  # type: ignore
        )
