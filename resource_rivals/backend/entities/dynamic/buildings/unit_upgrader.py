from entities.dynamic.buildings.building import Building
from entities.dynamic.units.advanced_ranged import AdvancedRanged
from entities.dynamic.units.advanced_soldier import AdvancedSoldier
from entities.dynamic.units.advanced_tank import AdvancedTank
from entities.dynamic.units.cavalry import Cavalry
from entities.dynamic.units.ranged import Ranged
from entities.dynamic.units.scout import Scout
from entities.dynamic.units.soldier import Soldier
from entities.dynamic.units.tank import Tank
from entities.entity import ConcreteEntity


class UnitUpgrader(Building, ConcreteEntity):
    def on_turn_end(self, game) -> None:
        super().on_turn_end(game)
        self.upgrade_unit(game, Tank, AdvancedTank)
        self.upgrade_unit(game, Soldier, AdvancedSoldier)
        self.upgrade_unit(game, Ranged, AdvancedRanged)
        self.upgrade_unit(game, Scout, Cavalry)
