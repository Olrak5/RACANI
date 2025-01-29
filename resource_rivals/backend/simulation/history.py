from typing import List

from pydantic import Field

from simulation.actions.action import Action
from simulation.map import Map
from utils.root_model import RootModel


class History(RootModel):
    actions: List[Action] = Field(default_factory=list)
    mapStates: List[Map] = Field(default_factory=list)
