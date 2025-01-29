from typing import Optional

from simulation.actions.action import ConcreteAction
from simulation.actions.game.team.team_action import TeamAction
from simulation.actions.response import Response
from simulation.team import Team


class ReadRequest(TeamAction, ConcreteAction):
    pass


class ReadResponse(Response):
    team: Optional[Team]
