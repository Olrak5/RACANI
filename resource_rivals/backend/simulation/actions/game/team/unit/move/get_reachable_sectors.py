from typing import List, Optional

from simulation.actions.action import ConcreteAction
from simulation.actions.game.team.unit.move.move_action import MoveAction
from simulation.actions.response import Response
from utils.math import Point


class GetReachableSectorsRequest(MoveAction, ConcreteAction):
    pass


class GetReachableSectorsResponse(Response):
    sectors: Optional[List[Point]]
