from typing import Type, Union, Dict

import yaml

from utils.root_model import RootModel


class JsonSerde:
    @staticmethod
    def save_model(model: RootModel, model_path: str):
        with open(model_path, "w") as file:
            file.write(model.model_dump_json())

    @staticmethod
    def load_model(model_cls: Type[RootModel], model_path: str):
        with open(model_path, "r") as file:
            return model_cls.model_validate_json(file.read())


class YamlSerde:
    @staticmethod
    def save_model(model: RootModel, model_path: str):
        with open(model_path, "w") as file:
            yaml.dump(model.model_dump(), file)

    @staticmethod
    def load_model(model_cls: Type[RootModel], model_path: str):
        with open(model_path, "r") as file:
            model = yaml.safe_load(file)
            return model_cls.model_validate(model)


EXTENSION_MAP: Dict[str, Type[Union[JsonSerde, YamlSerde]]] = {
    "json": JsonSerde,
    "yaml": YamlSerde,
    "yml": YamlSerde
}


class ModelSerde:
    @staticmethod
    def save_model(model: RootModel, model_path: str):
        extension = model_path.split(".")[-1]
        serde: Type[Union[JsonSerde, YamlSerde]] = EXTENSION_MAP[extension]
        serde.save_model(model, model_path)

    @staticmethod
    def load_model(model_cls: Type[RootModel], model_path: str):
        extension = model_path.split(".")[-1]
        serde: Type[Union[JsonSerde, YamlSerde]] = EXTENSION_MAP[extension]
        return serde.load_model(model_cls, model_path)
