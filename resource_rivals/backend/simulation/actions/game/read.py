from typing import Optional

from simulation.actions.action import ConcreteAction
from simulation.actions.game.game_action import GameAction
from simulation.actions.response import Response
from simulation.game import Game


class ReadRequest(GameAction, ConcreteAction):
    pass


class ReadResponse(Response):
    game: Optional[Game]
