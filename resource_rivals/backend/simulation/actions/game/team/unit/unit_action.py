from simulation.actions.action import Action


class UnitAction(Action):
    @classmethod
    def get_namespace(cls) -> str:
        return "game/team/unit"
