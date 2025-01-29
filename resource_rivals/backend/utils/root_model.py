from pydantic import ConfigDict, BaseModel


class RootModel(BaseModel):
    model_config = ConfigDict(extra="allow")
