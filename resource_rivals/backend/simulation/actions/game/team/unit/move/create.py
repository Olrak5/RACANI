from simulation.actions.action import ConcreteAction
from simulation.actions.game.team.unit.move.move_action import MoveAction

from utils.math import Point


class CreateRequest(MoveAction, ConcreteAction):
    targetPosition: Point
