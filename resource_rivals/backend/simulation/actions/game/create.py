from typing import Optional

from simulation.actions.action import ConcreteAction
from simulation.actions.game.game_action import GameAction
from simulation.actions.response import Response
from simulation.game import Game


class CreateRequest(GameAction, ConcreteAction):
    mapName: str


class CreateResponse(Response):
    game: Optional[Game]
