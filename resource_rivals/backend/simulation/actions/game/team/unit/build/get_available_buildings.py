from typing import List, Optional

from simulation.actions.action import ConcreteAction
from simulation.actions.game.team.unit.build.build_action import BuildAction
from simulation.actions.response import Response


class GetAvailableBuildingsRequest(BuildAction, ConcreteAction):
    pass


class GetAvailableBuildingsResponse(Response):
    availableBuildings: Optional[List[List[str]]]  # (namespace, type) tuples
