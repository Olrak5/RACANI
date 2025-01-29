from simulation.actions.action import Action


class MoveAction(Action):
    @classmethod
    def get_namespace(cls) -> str:
        return "game/team/unit/move"
