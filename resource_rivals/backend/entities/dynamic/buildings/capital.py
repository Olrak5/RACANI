from entities.dynamic.buildings.building import Building
from entities.dynamic.units.worker import Worker
from entities.entity import ConcreteEntity


class Capital(Building, ConcreteEntity):
    def _handle_conquering(self, game) -> None:
        if self._is_conquered(game):
            game.teams[self.teamId].isDefeated = True

    def on_turn_start(self, game) -> None:
        super().on_turn_start(game)
        self.generate_unit(game, Worker)
