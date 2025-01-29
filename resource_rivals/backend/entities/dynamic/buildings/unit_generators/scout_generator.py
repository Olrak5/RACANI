from entities.dynamic.buildings.unit_generators.unit_generator import \
    UnitGenerator
from entities.dynamic.units.scout import Scout
from entities.dynamic.units.worker import Worker
from entities.entity import ConcreteEntity


class ScoutGenerator(UnitGenerator, ConcreteEntity):
    def on_turn_end(self, game) -> None:
        super().on_turn_end(game)
        self.upgrade_unit(game, Worker, Scout)
