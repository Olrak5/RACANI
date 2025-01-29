from entities.dynamic.buildings.building import Building


class ResourceCollector(Building):
    @classmethod
    def get_namespace(cls) -> str:
        return "buildings/resource_collectors"
