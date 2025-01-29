from enum import Enum
from typing import Callable, Set
from uuid import uuid4

from pydantic import Field

from utils.root_model import RootModel


class Observer(RootModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    callback: Callable

    def __hash__(self):
        return hash(self.id)


class Observable(RootModel):
    observers: Set[Observer] = Field(default_factory=set)

    def add_observer(self, observer: Observer) -> None:
        self.observers.add(observer)

    def remove_observer(self, observer: Observer) -> None:
        self.observers.remove(observer)

    def notify_observers(self, *args, **kwargs):
        if "event" not in kwargs:
            raise ValueError("Event type not specified")

        for observer in self.observers:
            observer.callback(*args, **kwargs)


class ObserverEvent(str, Enum):
    ADDED = "added"
    REMOVED = "removed"
    UPDATED = "updated"
