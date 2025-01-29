from typing import List, Optional

from pydantic import SerializeAsAny

from entities.entity import Entity
from simulation.actions.action import ConcreteAction
from simulation.actions.game.team.team_action import TeamAction
from simulation.actions.response import Response


class GetVisibleMapRequest(TeamAction, ConcreteAction):
    pass


class GetVisibleMapResponse(Response):
    sectors: Optional[List[List[Optional[List[SerializeAsAny[Entity]]]]]]
