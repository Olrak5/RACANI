from typing import List, Set

from consts import UNITS_CONFIG
from entities.entity import Entity
from entities.static.obstacles.obstacle import Obstacle
from utils.logger import get_logger
from utils.math import Point

logger = get_logger("unit")


class Unit(Entity):
    health: int
    armor: int
    damage: int
    movementRange: int
    attackRange: int

    def __init__(self, **kwargs):
        kwargs['health'] = self.get_health()
        kwargs['armor'] = self.get_armor()
        kwargs['damage'] = self.get_damage()
        kwargs['movementRange'] = self.get_movement_range()
        kwargs['attackRange'] = self.get_attack_range()

        super().__init__(**kwargs)

    def act(self, target_position: Point, _map) -> None:
        target_sector = _map.get_entities_at_position(
            target_position.x,
            target_position.y
        )
        target = None

        for entity in target_sector:
            if isinstance(entity, Unit) and entity.teamId != self.teamId:
                target = entity
                break

        if target is None:
            self.move(target_position, _map)
        else:
            self.attack(target, _map)

    def attack(self, target: 'Unit', _map) -> None:
        if not self._check_in_attack_range(target.position):
            raise ValueError("Target is out of range")

        if self.teamId == target.teamId:
            raise ValueError("Cannot attack friendly units")

        target._defend(self, self.damage)
        if target.health <= 0:
            _map.remove_entity(target)
        else:
            _map.update_entity(target)

        if self.health <= 0:
            _map.remove_entity(self)
        else:
            _map.update_entity(self)

    def move(self, target: Point, _map) -> None:
        if (
                target
                not in self._calculate_movable_sectors_in_range(_map.sectors)
        ):
            raise ValueError("Target is out of range")

        if self._is_path_blocked(
                self.position, target, _map.sectors, self.movementRange
        ):
            raise ValueError("Path to target is blocked by obstacles")

        self.position = target
        _map.update_entity(self)

    def calculate_reachable_sectors(
            self, sectors: List[List[List[Entity]]]
    ) -> List[Point]:
        logger.debug(f"Calculating reachable sectors for {self}")
        logger.debug(f"Current position: {self.position}")

        sectors_in_range = self._calculate_movable_sectors_in_range(sectors)
        reachable_sectors = []

        for sector in sectors_in_range:
            if not self._is_path_blocked(
                    self.position, sector, sectors, self.movementRange
            ):
                reachable_sectors.append(sector)

        for sector in self._calculate_attackable_sectors_in_range(sectors):
            if sector not in reachable_sectors:
                reachable_sectors.append(sector)

        logger.debug(f"Reachable sectors: {reachable_sectors}")

        return reachable_sectors

    def _calculate_movable_sectors_in_range(
            self, sectors: List[List[List[Entity]]]
    ) -> List[Point]:
        movable_sectors = []

        for y, row in enumerate(sectors):
            for x, sector in enumerate(row):
                if (
                        self._check_in_movement_range(Point(x, y))
                        and self._sector_free(sectors[y][x])
                ):
                    movable_sectors.append(Point(x, y))

        return movable_sectors

    def _calculate_attackable_sectors_in_range(
            self, sectors: List[List[List[Entity]]]
    ) -> List[Point]:
        attackable_sectors = []

        for y, row in enumerate(sectors):
            for x, sector in enumerate(row):
                if (
                        self._check_in_attack_range(Point(x, y))
                        and self._contains_enemy_unit(sectors[y][x])
                ):
                    attackable_sectors.append(Point(x, y))

        return attackable_sectors

    def _is_path_blocked(
            self,
            start: Point, end: Point,
            sectors: List[List[List[Entity]]],
            max_path_length: int
    ) -> bool:
        explored = set()
        queue = [(start, 0)]

        def get_neighbors(current, sectors):
            neighbors = []
            for i in range(-1, 2):
                for j in range(-1, 2):
                    if i == 0 and j == 0:
                        continue

                    x = current.x + i
                    y = current.y + j

                    if (
                            x >= 0 and x < len(sectors[0])
                            and y >= 0 and y < len(sectors)
                    ):
                        neighbors.append(Point(x, y))

            return neighbors

        while queue:
            current, path_length = queue.pop(0)
            explored.add(current)

            if current == end:
                return False

            if path_length >= max_path_length:
                continue

            for neighbor in get_neighbors(current, sectors):
                neighbor_unexplored = neighbor not in explored
                sector_free = self._sector_free(
                    sectors[neighbor.y][neighbor.x]
                )
                if neighbor_unexplored and sector_free:
                    queue.append((neighbor, path_length + 1))

        return True

    def calculate_visible_area(
            self, max_width: int, max_height: int
    ) -> Set[Point]:
        logger.debug(f"Calculating visible area for {self.id}")

        visible_sectors = set()

        max_range = max(self.movementRange, self.attackRange)

        for x in range(
                self.position.x - max_range,
                self.position.x + max_range + 1
        ):
            for y in range(
                    self.position.y - max_range,
                    self.position.y + max_range + 1
            ):
                if (
                        x < 0 or x >= max_width
                        or y < 0 or y >= max_height
                ):
                    continue
                visible_sectors.add(Point(x, y))

        logger.debug(f"Visible area for {self.id}: {visible_sectors}")

        return visible_sectors

    def get_health(self) -> int:
        return UNITS_CONFIG[self.__class__.__name__]['health']

    def get_armor(self) -> int:
        return UNITS_CONFIG[self.__class__.__name__]['armor']

    def get_damage(self) -> int:
        return UNITS_CONFIG[self.__class__.__name__]['damage']

    def get_movement_range(self) -> int:
        return UNITS_CONFIG[self.__class__.__name__]['movementRange']

    def get_attack_range(self) -> int:
        return UNITS_CONFIG[self.__class__.__name__]['attackRange']

    def calculate_available_buildings(
            self, game
    ) -> List[List[str]]:  # (namespace, type) tuples
        return []

    def _defend(self, attacker: 'Unit', damage: int) -> None:
        self._hurt(damage)

        if self.health > 0:
            if self._check_in_attack_range(attacker.position):
                attacker._hurt(self.damage)

    def _hurt(self, damage: int) -> None:
        self.health -= max(damage - self.armor, 0)

    def _check_in_attack_range(self, target: Point) -> bool:
        if (
                abs(self.position.x - target.x) <= self.attackRange
                and abs(self.position.y - target.y) <= self.attackRange
        ):
            return True

        return False

    def _check_in_movement_range(self, target: Point) -> bool:
        if (
                abs(self.position.x - target.x) <= self.movementRange
                and abs(self.position.y - target.y) <= self.movementRange
        ):
            return True

        return False

    def _sector_free(self, sector: List[Entity]) -> bool:
        for entity in sector:
            if isinstance(entity, Obstacle) or isinstance(entity, Unit):
                return False

        return True

    def _contains_enemy_unit(self, sector: List[Entity]) -> bool:
        for entity in sector:
            if isinstance(entity, Unit) and entity.teamId != self.teamId:
                return True

        return False

    @classmethod
    def get_namespace(cls) -> str:
        return "units"
