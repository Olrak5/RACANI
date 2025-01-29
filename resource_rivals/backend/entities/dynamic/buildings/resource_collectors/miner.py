from consts import RESOURCE_COLLECTORS_YIELD
from entities.dynamic.buildings.resource_collectors.resource_collector import \
    ResourceCollector
from entities.entity import ConcreteEntity


class Miner(ResourceCollector, ConcreteEntity):
    def on_turn_end(self, game) -> None:
        super().on_turn_end(game)
        game.teams[self.teamId].resources.minerals += (
            RESOURCE_COLLECTORS_YIELD[Miner.__name__]
        )
