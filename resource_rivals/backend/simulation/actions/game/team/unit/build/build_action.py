from simulation.actions.action import Action


class BuildAction(Action):
    @classmethod
    def get_namespace(cls) -> str:
        return "game/team/unit/build"
