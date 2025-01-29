from consts import RESOURCE_COLLECTORS_YIELD
from entities.dynamic.buildings.resource_collectors.resource_collector import \
    ResourceCollector
from entities.entity import ConcreteEntity


class Sawmill(ResourceCollector, ConcreteEntity):
    def on_turn_end(self, game) -> None:
        super().on_turn_end(game)
        game.teams[self.teamId].resources.wood += (
            RESOURCE_COLLECTORS_YIELD[Sawmill.__name__]
        )
