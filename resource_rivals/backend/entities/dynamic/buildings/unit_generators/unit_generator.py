from entities.dynamic.buildings.building import Building


class UnitGenerator(Building):
    @classmethod
    def get_namespace(cls) -> str:
        return "buildings/unit_generators"
