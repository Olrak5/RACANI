from enum import Enum


class GameStates(str, Enum):
    BEFORE_START = "before_start"
    IN_PROGRESS = "in_progress"
    FINISHED = "finished"
