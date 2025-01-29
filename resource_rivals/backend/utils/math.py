from utils.root_model import RootModel


class Point(RootModel):
    x: int
    y: int

    def __init__(self, x: int, y: int, **kwargs):
        super().__init__(x=x, y=y, **kwargs)  # type: ignore

    def __hash__(self):
        return hash((self.x, self.y))
