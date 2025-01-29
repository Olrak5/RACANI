from typing import List, Type, Optional, Set

from consts import BUILDING_COSTS, BUILDING_INFLUENCE_SIZE
from entities.dynamic.units.unit import Unit
from entities.entity import Entity
from utils.math import Point


class Building(Entity):
    cost: List[int]  # food, wood, minerals

    def __init__(self, **kwargs):
        kwargs['cost'] = self.get_cost()
        super().__init__(**kwargs)

    def calculate_influence(
            self,
            sectors: List[List[List['Entity']]]
    ) -> Set[Point]:
        influence_cloud = set()
        influence_size = BUILDING_INFLUENCE_SIZE[self.__class__.__name__]
        for y in range(len(sectors)):
            for x in range(len(sectors[y])):
                if (
                        abs(self.position.y - y) <= influence_size
                        and abs(self.position.x - x) <= influence_size
                ):
                    influence_cloud.add(Point(x, y))

        return influence_cloud

    def on_turn_start(self, game) -> None:
        super().on_turn_start(game)
        self._handle_conquering(game)

    @classmethod
    def get_namespace(cls) -> str:
        return "buildings"

    def generate_unit(self, game, unit_type: Type[Unit]) -> None:
        if self._can_generate_unit(game):
            game.map.add_entity(
                unit_type(
                    position=self.position,
                    teamId=self.teamId,
                )
            )

    def upgrade_unit(
            self, game, source_type: Type[Unit], target_type: Type[Unit]
    ) -> None:
        if unit := self._contains_unit(game, source_type):
            game.map.remove_entity(unit)
            self.generate_unit(game, target_type)

    def get_cost(self) -> List[int]:
        return BUILDING_COSTS[self.__class__.__name__]

    def _can_generate_unit(self, game) -> bool:
        current_sector = game.map.sectors[self.position.y][self.position.x]
        current_population = (
            game.teams[self.teamId].get_current_population(game.map)
        )
        max_population = game.teams[self.teamId].maxPopulation
        return len(current_sector) == 1 and current_population < max_population

    def _contains_unit(self, game, unit_type: Type[Unit]) -> Optional[Unit]:
        for entity in game.map.sectors[self.position.y][self.position.x]:
            if isinstance(entity, unit_type):
                return entity
        return None

    def _handle_conquering(self, game) -> None:
        if self._is_conquered(game):
            game.map.remove_entity(self)

    def _is_conquered(self, game) -> bool:
        current_sector = game.map.sectors[self.position.y][self.position.x]
        for entity in current_sector:
            if isinstance(entity, Unit) and entity.teamId != self.teamId:
                return True

        return False
