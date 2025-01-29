from typing import Optional

from pydantic import SerializeAsAny

from entities.entity import Entity
from simulation.actions.action import ConcreteAction
from simulation.actions.game.team.unit.build.build_action import BuildAction
from simulation.actions.response import Response


class CreateRequest(BuildAction, ConcreteAction):
    buildingType: str
    buildingNamespace: str


class CreateResponse(Response):
    building: Optional[SerializeAsAny[Entity]]
