from consts import TEAMS_NEUTRAL_ID
from simulation.actions.action import Action


class GameAction(Action):
    teamId: str = TEAMS_NEUTRAL_ID

    @classmethod
    def get_namespace(cls) -> str:
        return "game"
