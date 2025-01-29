from entities.dynamic.buildings.unit_generators.unit_generator import \
    UnitGenerator
from entities.dynamic.units.soldier import Soldier
from entities.dynamic.units.worker import Worker
from entities.entity import ConcreteEntity


class SoldierGenerator(UnitGenerator, ConcreteEntity):
    def on_turn_end(self, game) -> None:
        super().on_turn_end(game)
        self.upgrade_unit(game, Worker, Soldier)
