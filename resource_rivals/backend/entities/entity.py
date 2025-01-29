from uuid import uuid4

from pydantic import Field

from utils.math import Point
from utils.root_model import RootModel


class Entity(RootModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    position: Point
    teamId: str
    type: str
    namespace: str

    def on_turn_start(self, game) -> None:
        pass

    def on_turn_end(self, game) -> None:
        pass

    @classmethod
    def get_type(cls) -> str:
        return cls.__name__

    @classmethod
    def get_namespace(cls) -> str:
        raise NotImplementedError("Namespace must be implemented in subclass")

    # This is a hack to make the type field default to
    # the class name for all subclasses
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        cls.model_fields['type'].default_factory = cls.get_type
        cls.model_fields['namespace'].default_factory = cls.get_namespace

    # This is a hack to turn the base class into a concrete class when
    # deserializing
    def model_post_init(self, *_) -> None:
        from utils.registry import registry

        if isinstance(self, ConcreteEntity):
            return

        actual_cls = registry.get(self.type, self.namespace)

        if not issubclass(actual_cls, Entity):
            raise ValueError(
                f"Class {actual_cls} is not a subclass of {Entity}"
            )

        actual_cls_instance = actual_cls(**self.model_dump())
        self.__class__ = actual_cls_instance.__class__
        self.__pydantic_private__ = actual_cls_instance.__pydantic_private__
        self.__dict__.update(actual_cls_instance.__dict__)

    def __hash__(self):
        return hash(self.id)


class ConcreteEntity(Entity):
    pass
