from pathlib import Path

from fastapi import APIRouter, Request, Response

from consts import MAP_DIR
from entities.dynamic.units.unit import Unit
from entities.dynamic.units.worker import Worker
from server import server
from simulation.actions.response import Response as GenericResponse
from simulation.actions.game.create import (
    CreateResponse as GameCreateResponse, CreateRequest as GameCreateRequest
)
from simulation.actions.game.read import ReadResponse as GameReadResponse

from simulation.actions.game.team.create import (
    CreateResponse as TeamCreateResponse, CreateRequest as TeamCreateRequest
)
from simulation.actions.game.team.get_visible_map import (
    GetVisibleMapResponse as TeamGetVisibleMapResponse
)
from simulation.actions.game.team.read import ReadResponse as TeamReadResponse

from simulation.actions.game.team.unit.build.create import (
    CreateResponse as BuildCreateResponse, CreateRequest as BuildCreateRequest
)
from simulation.actions.game.team.unit.build.get_available_buildings import (
    GetAvailableBuildingsResponse as UnitGetAvailableBuildingsResponse
)
from simulation.actions.game.team.unit.move.create import (
    CreateRequest as MoveCreateRequest
)
from simulation.actions.game.team.unit.move.get_reachable_sectors import (
    GetReachableSectorsResponse as UnitGetReachableSectorsResponse
)


api_router = APIRouter(prefix="/api/v1")


@api_router.post("/game", response_model=GameCreateResponse)
async def create_game(
        request: Request, response: Response
) -> GameCreateResponse:
    try:
        request = await request.json()
        parsed_request = GameCreateRequest(**request)
    except Exception as e:
        response.status_code = 400
        return GameCreateResponse(
            error=f"Invalid parameters ({e})", game=None
        )

    try:
        base_map_path = f"{MAP_DIR}/{parsed_request.mapName}"
        for extension in ["json", "yaml"]:
            map_path = f"{base_map_path}.{extension}"
            if Path(map_path).exists():
                break

        if not Path(map_path).exists():
            return GameCreateResponse(
                error=f"Map {parsed_request.mapName} not found", game=None
            )

        created_game = server.create_game(
            map_path=map_path
        )
    except ValueError as e:
        response.status_code = 400
        return GameCreateResponse(error=str(e), game=None)

    return GameCreateResponse(game=created_game)


@api_router.get("/game/{game_id}", response_model=GameReadResponse)
async def read_game(game_id: str, response: Response) -> GameReadResponse:
    try:
        game = server.get_game(game_id)
    except ValueError as e:
        response.status_code = 400
        return GameReadResponse(error=str(e), game=None)

    return GameReadResponse(game=game)


@api_router.delete("/game/{game_id}", response_model=None)
async def delete_game(game_id: str, response: Response) -> GenericResponse:
    try:
        server.delete_game(game_id)
    except ValueError as e:
        response.status_code = 400
        return GenericResponse(error=str(e))

    return GenericResponse()


@api_router.post("/game/{game_id}/start", response_model=None)
async def start_game(game_id: str, response: Response) -> GenericResponse:
    try:
        server.get_game(game_id).start()
    except ValueError as e:
        response.status_code = 400
        return GenericResponse(error=str(e))

    return GenericResponse()


@api_router.post("/game/{game_id}/team", response_model=TeamCreateResponse)
async def create_team(
        game_id: str, request: Request, response: Response
) -> TeamCreateResponse:
    try:
        request = await request.json()
        parsed_request = TeamCreateRequest(**request)
    except Exception as e:
        response.status_code = 400
        return TeamCreateResponse(
            error=f"Invalid parameters ({e})", team=None
        )

    try:
        created_team = server.get_game(game_id).register_team(
            name=parsed_request.name
        )
    except ValueError as e:
        response.status_code = 400
        return TeamCreateResponse(error=str(e), team=None)

    return TeamCreateResponse(team=created_team)


@api_router.get(
    "/game/{game_id}/team/{team_id}", response_model=TeamReadResponse
)
async def read_team(
        game_id: str, team_id: str, response: Response
) -> TeamReadResponse:
    try:
        team = server.get_game(game_id).teams[team_id]
    except ValueError as e:
        response.status_code = 400
        return TeamReadResponse(error=str(e), team=None)

    return TeamReadResponse(team=team)


@api_router.get(
    "/game/{game_id}/team/{team_id}/visible-map",
    response_model=TeamGetVisibleMapResponse
)
async def get_visible_map(
        game_id: str, team_id: str, response: Response
) -> TeamGetVisibleMapResponse:
    try:
        game = server.get_running_game(game_id)
        team = game.teams[team_id]
        visible_map = team.get_visible_map(game.map)
    except ValueError as e:
        response.status_code = 400
        return TeamGetVisibleMapResponse(error=str(e), sectors=None)

    return TeamGetVisibleMapResponse(sectors=visible_map)


@api_router.post(
    "/game/{game_id}/team/{team_id}/end-turn", response_model=None
)
async def end_turn(
        game_id: str, team_id: str, response: Response
) -> GenericResponse:
    try:
        server.get_running_game(game_id).end_turn()
    except ValueError as e:
        response.status_code = 400
        return GenericResponse(error=str(e))

    return GenericResponse()


@api_router.post(
    "/game/{game_id}/team/{team_id}/unit/{unit_id}/build",
    response_model=BuildCreateResponse
)
async def create_building(
        game_id: str, team_id: str, unit_id: str,
        request: Request, response: Response
) -> BuildCreateResponse:
    try:
        request = await request.json()
        parsed_request = BuildCreateRequest(**request, teamId=team_id)
    except Exception as e:
        response.status_code = 400
        return BuildCreateResponse(
            error=f"Invalid parameters ({e})", building=None
        )

    try:
        game = server.get_running_game(game_id)
        unit = game.map.entities[unit_id]
        if not isinstance(unit, Worker):
            raise ValueError(
                f"Only workers can build. Selected unit type: {unit.type}"
            )
        building = unit.build(
            parsed_request.buildingNamespace, parsed_request.buildingType, game
        )
        game.teams[team_id].recalculate_visible_area(game.map)
    except ValueError as e:
        response.status_code = 400
        return BuildCreateResponse(error=str(e), building=None)

    return BuildCreateResponse(building=building)


@api_router.get(
    "/game/{game_id}/team/{team_id}/unit/{unit_id}/build/available-buildings",
    response_model=UnitGetAvailableBuildingsResponse
)
async def get_available_buildings(
        game_id: str, team_id: str, unit_id: str, response: Response
) -> UnitGetAvailableBuildingsResponse:
    try:
        game = server.get_running_game(game_id)
        unit = game.map.expect_entity_by_id(unit_id)
        if not isinstance(unit, Worker):
            raise ValueError(
                f"Only workers can build. Selected unit type: {unit.type}"
            )
        available_buildings = unit.calculate_available_buildings(game)
    except ValueError as e:
        response.status_code = 400
        return UnitGetAvailableBuildingsResponse(
            error=str(e), availableBuildings=None
        )

    return UnitGetAvailableBuildingsResponse(
        availableBuildings=available_buildings
    )


@api_router.post(
    "/game/{game_id}/team/{team_id}/unit/{unit_id}/move",
    response_model=None
)
async def move_unit(
        game_id: str, team_id: str, unit_id: str,
        request: Request, response: Response
) -> GenericResponse:
    try:
        request = await request.json()
        parsed_request = MoveCreateRequest(**request, teamId=team_id)
    except Exception as e:
        response.status_code = 400
        return GenericResponse(error=f"Invalid parameters ({e})")

    try:
        game = server.get_running_game(game_id)
        unit = game.map.expect_entity_by_id(unit_id)
        if not isinstance(unit, Unit):
            raise ValueError(
                f"Only units can move/attack. "
                f"Selected entity type: {unit.type}"
            )
        if unit.teamId != team_id:
            raise ValueError("Unit does not belong to the team")
        if unit.id in game.movedUnits:
            raise ValueError("Unit has already moved this turn")
        unit.act(parsed_request.targetPosition, game.map)
        game.movedUnits.add(unit.id)
        game.teams[team_id].recalculate_visible_area(game.map)
    except ValueError as e:
        response.status_code = 400
        return GenericResponse(error=str(e))

    return GenericResponse()


@api_router.get(
    "/game/{game_id}/team/{team_id}/unit/{unit_id}/move/reachable-sectors",
    response_model=UnitGetReachableSectorsResponse
)
async def get_reachable_sectors(
        game_id: str, team_id: str, unit_id: str, response: Response
) -> UnitGetReachableSectorsResponse:
    try:
        game = server.get_running_game(game_id)
        unit = game.map.expect_entity_by_id(unit_id)
        if not isinstance(unit, Unit):
            raise ValueError(
                f"Only units can move/attack. "
                f"Selected entity type: {unit.type}"
            )
        if unit.teamId != team_id:
            raise ValueError("Unit does not belong to the team")
        if unit.id in game.movedUnits:
            raise ValueError("Unit has already moved this turn")
        reachable_sectors = unit.calculate_reachable_sectors(game.map.sectors)
    except ValueError as e:
        response.status_code = 400
        return UnitGetReachableSectorsResponse(
            error=str(e), sectors=None
        )

    return UnitGetReachableSectorsResponse(sectors=reachable_sectors)
