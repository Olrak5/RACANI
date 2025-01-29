from entities.dynamic.buildings.unit_generators.unit_generator import \
    UnitGenerator
from entities.dynamic.units.worker import Worker
from entities.entity import ConcreteEntity


class WorkerGenerator(UnitGenerator, ConcreteEntity):
    def on_turn_end(self, game) -> None:
        super().on_turn_end(game)
        self.generate_unit(game, Worker)
