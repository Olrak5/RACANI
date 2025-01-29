from typing import Set, List, Optional
from uuid import uuid4

from pydantic import Field

from consts import TEAMS_STARTING_POPULATION, TEAMS_STARTING_RESOURCES
from entities.dynamic.units.unit import Unit
from entities.entity import Entity
from simulation.map import Map
from utils.logger import get_logger
from utils.math import Point
from utils.root_model import RootModel

logger = get_logger("team")


class Resources(RootModel):
    food: int = TEAMS_STARTING_RESOURCES[0]
    wood: int = TEAMS_STARTING_RESOURCES[1]
    minerals: int = TEAMS_STARTING_RESOURCES[2]

    def can_afford(self, cost: "Resources") -> bool:
        return all(
            getattr(self, resource) >= getattr(cost, resource)
            for resource in self.model_fields.keys()
        )

    def pay(self, cost: "Resources") -> None:
        if not self.can_afford(cost):
            raise ValueError("Not enough resources")

        for resource in self.model_fields.keys():
            setattr(
                self, resource,
                getattr(self, resource) - getattr(cost, resource)
            )


class Team(RootModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    name: str
    visibleArea: Set[Point] = Field(default_factory=set)
    resources: Resources = Resources()
    maxPopulation: int = TEAMS_STARTING_POPULATION
    isDefeated: bool = False

    def get_current_population(self, _map: Map) -> int:
        population = 0
        for entity in _map.get_entities_by_team(self.id):
            if isinstance(entity, Unit):
                population += 1

        return population

    def recalculate_visible_area(self, _map: Map) -> None:
        logger.debug(f"Recalculating visible area for team: {self.id}")

        for entity in _map.get_entities_by_team(self.id):
            logger.debug(f"Entity: {entity}")
            if isinstance(entity, Unit):
                self.visibleArea.update(
                    entity.calculate_visible_area(_map.width, _map.height)
                )

    def get_visible_map(self, _map: Map) -> List[List[Optional[List[Entity]]]]:
        logger.debug("Getting visible map")

        logger.debug(f"Visible area: {self.visibleArea}")

        visible_map = _map.model_copy(deep=True)
        visible_sectors: List[List[Optional[List[Entity]]]] = (
            visible_map.sectors  # type: ignore
        )

        for x in range(visible_map.width):
            for y in range(visible_map.height):
                if Point(x, y) not in self.visibleArea:
                    visible_sectors[y][x] = None

        return visible_sectors
