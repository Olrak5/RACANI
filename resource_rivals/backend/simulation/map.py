from typing import List, Optional, Set, Collection, Dict

from pydantic import SerializeAsAny

from consts import TEAMS_NEUTRAL_ID
from entities.entity import Entity
from utils.logger import get_logger
from utils.model_serde import ModelSerde
from utils.root_model import RootModel

logger = get_logger("map")


class Map(RootModel):
    sectors: List[List[List[SerializeAsAny[Entity]]]]
    entities: Dict[str, SerializeAsAny[Entity]]
    influence: List[List[str]]  # 2D array of team ids

    def add_entity(self, entity: Entity):
        entity = entity.model_copy(deep=True)

        self.entities[entity.id] = entity
        self.sectors[entity.position.y][entity.position.x].append(entity)
        self._recalculate_influence()

    def remove_entity(self, entity: Entity):
        old_entity = self.expect_entity_by_id(entity.id)

        del self.entities[old_entity.id]
        self.sectors[old_entity.position.y][old_entity.position.x].remove(
            old_entity
        )
        self._recalculate_influence()

    def update_entity(self, entity: Entity):
        logger.debug(f"Updating entity: {entity}")
        old_entity = self.expect_entity_by_id(entity.id)
        entity = entity.model_copy(deep=True)

        if old_entity == entity:
            logger.debug("Entity is the same, skipping update")
            return

        self.sectors[old_entity.position.y][old_entity.position.x].remove(
            old_entity
        )

        self.entities[entity.id] = entity
        self.sectors[entity.position.y][entity.position.x].append(entity)
        self._recalculate_influence()

    def get_entities_at_position(self, x: int, y: int) -> List[Entity]:
        return [entity.model_copy(deep=True) for entity in self.sectors[y][x]]

    def get_entity_by_id(self, _id: str) -> Optional[Entity]:
        entity = self.entities.get(_id, None)
        if entity is None:
            return None
        return entity.model_copy(deep=True)

    def expect_entity_by_id(self, _id: str) -> Entity:
        entity = self.get_entity_by_id(_id)
        if entity is None:
            raise ValueError(f"Entity with id '{_id}' not found in map")
        return entity

    def add_entities(self, entities: Collection[Entity]):
        for entity in entities:
            self.add_entity(entity)

    def remove_entities(self, entities: Collection[Entity]):
        for entity in entities:
            self.remove_entity(entity)

    def update_entities(self, entities: Collection[Entity]):
        for entity in entities:
            self.update_entity(entity)

    def get_entities(self) -> Set[Entity]:
        return {
            entity.model_copy(deep=True) for entity in self.entities.values()
        }

    def get_entities_by_team(self, team_id: str) -> Set[Entity]:
        return {
            entity.model_copy(deep=True) for entity in self.entities.values()
            if entity.teamId == team_id
        }

    @property
    def width(self) -> int:
        return len(self.sectors[0])

    @property
    def height(self) -> int:
        return len(self.sectors)

    @staticmethod
    def from_entities(entities: Collection[Entity], w: int, h: int) -> 'Map':
        sectors: List[List[List[Entity]]] = [
            [[] for _ in range(w)] for _ in range(h)
        ]
        influence: List[List[str]] = [
            [TEAMS_NEUTRAL_ID for _ in range(w)] for _ in range(h)
        ]

        for entity in entities:
            sectors[entity.position.y][entity.position.x].append(entity)

        entities_map = {entity.id: entity for entity in entities}

        return Map(
            sectors=sectors, entities=entities_map, influence=influence
        )

    @staticmethod
    def from_file(file_path: str) -> 'Map':
        tree = ModelSerde.load_model(Map, file_path)

        return tree

    def _recalculate_influence(self) -> None:
        for entity in self.entities.values():
            if getattr(entity, "calculate_influence", None) is None:
                continue

            influence_cloud = entity.calculate_influence(  # type: ignore
                self.sectors
            )
            for position in influence_cloud:
                x, y = position.x, position.y
                self.influence[y][x] = entity.teamId
