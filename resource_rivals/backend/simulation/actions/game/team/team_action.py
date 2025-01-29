from simulation.actions.action import Action


class TeamAction(Action):
    @classmethod
    def get_namespace(cls) -> str:
        return "game/team"
