import inspect
import os
from importlib import import_module
from typing import Type, List

from consts import REGISTRY_SEARCH_PATHS, REGISTRY_BASE_CLASSES
from utils.logger import get_logger
from utils.root_model import RootModel

logger = get_logger("registry")


class Registry:
    def __init__(self):
        self.modules = {}

        self.populate(REGISTRY_BASE_CLASSES)

    def register(self, module_cls: Type[RootModel]) -> None:
        logger.debug(f"Registering {module_cls.get_type()}")  # type: ignore
        self.modules[self._get_key_by_cls(module_cls)] = module_cls

    def get(self, name: str, namespace: str) -> Type[RootModel]:
        module = self.modules.get(self._get_key_by_name(name, namespace), None)
        if module is None:
            raise ValueError(f"Module {name} not found in registry")

        return module

    def populate(self, base_classes: List[str]) -> None:
        logger.info("Populating registry")

        base_classes_impl = []
        for base_cls in base_classes:
            module_name, cls = base_cls.rsplit(".", 1)
            module = import_module(module_name)
            base_classes_impl.append(getattr(module, cls))

        for search_path in REGISTRY_SEARCH_PATHS:
            logger.debug(f"Searching for entities in {search_path}")
            for dirpath, dirnames, filenames in os.walk(search_path):
                for filename in filenames:
                    logger.debug(f"Checking {filename}")
                    if not filename.endswith(".py"):
                        continue

                    module_path = dirpath.replace('/', '.').replace('\\', '.')
                    logger.debug(f"Importing {filename} from {module_path}")
                    module = import_module(f"{module_path}.{filename[:-3]}")
                    for name, module_cls in inspect.getmembers(
                            module, inspect.isclass
                    ):
                        logger.debug(f"Checking {name}")
                        for base_cls in base_classes_impl:
                            if (
                                    issubclass(
                                        module_cls, base_cls  # type: ignore
                                    )
                                    and module_cls != base_cls
                            ):
                                self.register(module_cls)

        logger.info(f"Populated registry with {len(self.modules)} modules")
        logger.debug(f"Registered modules: {list(self.modules.keys())}")

    @staticmethod
    def _get_key_by_cls(module_cls: Type[RootModel]) -> str:
        return Registry._get_key_by_name(
            module_cls.get_type(), module_cls.get_namespace()  # type: ignore
        )

    @staticmethod
    def _get_key_by_name(name: str, namespace: str) -> str:
        return f"{namespace}/{name}"

    def __iter__(self):
        return iter(self.modules.values())

    def __len__(self):
        return len(self.modules)

    def __contains__(self, name: str, namespace: str):
        return self._get_key_by_name(name, namespace) in self.modules


registry = Registry()
