from uuid import uuid4

from pydantic import Field

from utils.root_model import RootModel


class Action(RootModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    teamId: str
    type: str
    namespace: str

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

        if isinstance(self, ConcreteAction):
            return

        actual_cls = registry.get(self.type, self.namespace)
        if not issubclass(actual_cls, Action):
            raise ValueError(
                f"Class {actual_cls} is not a subclass of {Action}"
            )

        actual_cls_instance = actual_cls(**self.model_dump())
        self.__class__ = actual_cls_instance.__class__
        self.__pydantic_private__ = actual_cls_instance.__pydantic_private__
        self.__dict__.update(actual_cls_instance.__dict__)


class ConcreteAction(Action):
    pass
