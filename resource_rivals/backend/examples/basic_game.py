import requests

from utils.logger import get_logger

logger = get_logger("examples.basic_game")
api_prefix = "http://localhost:8000/api/v1"


def create_game(map_name: str) -> str:
    logger.info("Creating game")

    create_game_url = f"{api_prefix}/game"
    response = requests.post(create_game_url, json={"mapName": map_name})

    if response.status_code != 200:
        raise ValueError(f"Error creating game: {response.json()}")

    game_id = response.json()["game"]["id"]

    logger.info(f"Game created with id: {game_id}")

    return game_id


def create_team(game_id: str, name: str) -> str:
    logger.info(f"Creating team with name {name}")

    create_team_url = f"{api_prefix}/game/{game_id}/team"
    response = requests.post(create_team_url, json={"name": name})

    if response.status_code != 200:
        raise ValueError(f"Error creating team: {response.json()}")

    response_dict = response.json()

    team_id = response_dict["team"]["id"]
    name = response_dict["team"]["name"]

    logger.info(f"Team created with id: {team_id} and name {name}")

    return team_id


def start_game(game_id: str) -> None:
    logger.info(f"Starting game {game_id}")

    start_game_url = f"{api_prefix}/game/{game_id}/start"
    response = requests.post(start_game_url)

    if response.status_code != 200:
        raise ValueError(f"Error starting game: {response.json()}")


def get_game_info(game_id: str) -> dict:
    logger.info(f"Getting game info for game {game_id}")

    get_game_info_url = f"{api_prefix}/game/{game_id}"
    response = requests.get(get_game_info_url)

    if response.status_code != 200:
        raise ValueError(f"Error getting game info: {response.json()}")

    game_info = response.json()["game"]

    logger.info(f"Game info: {game_info}")

    return game_info


def perform_turn(game_id: str, team_id: str):
    logger.info(f"Performing turn for team {team_id}")

    end_turn_url = f"{api_prefix}/game/{game_id}/team/{team_id}/end-turn"
    get_visible_map_url = \
        f"{api_prefix}/game/{game_id}/team/{team_id}/visible-map"

    response = requests.get(get_visible_map_url)
    if response.status_code != 200:
        logger.error(f"Error getting visible map: {response.json()}")
        return

    visible_map = response.json()["sectors"]
    visualize_map(visible_map)

    available_workers = []

    for i, row in enumerate(visible_map):
        for j, sector in enumerate(row):
            if not sector:
                continue

            logger.info(f"Sector {i}, {j} is visible")
            logger.debug(f"Entities in sector: {sector}")

            for entity in sector:
                if (
                        entity["type"] == "Worker"
                        and entity["teamId"] == team_id
                ):
                    logger.info(f"Friendly worker unit found at {i}, {j}")
                    logger.debug(f"Entity: {entity}")
                    available_workers.append(
                        [entity["id"], entity["position"]]
                    )

    if not available_workers:
        raise ValueError("No worker unit found to move")

    for selected_worker_id, worker_position in available_workers:
        logger.info(
            f"Moving worker unit {selected_worker_id} at {worker_position}"
        )

        get_reachable_sectors_url = (
            f"{api_prefix}/game/{game_id}/team/{team_id}/"
            f"unit/{selected_worker_id}/move/reachable-sectors"
        )
        response = requests.get(get_reachable_sectors_url)
        if response.status_code != 200:
            raise ValueError(
                f"Error getting reachable sectors: {response.json()}"
            )

        reachable_sectors = response.json()["sectors"]
        logger.info(f"Reachable sectors: {reachable_sectors}")

        if not reachable_sectors:
            logger.info("No reachable sectors found. Trying next worker")
            continue

        selected_sector = reachable_sectors[0]

        move_unit_url = (
            f"{api_prefix}/game/{game_id}/team/{team_id}/"
            f"unit/{selected_worker_id}/move"
        )
        response = requests.post(
            move_unit_url, json={"targetPosition": selected_sector}
        )

        if response.status_code != 200:
            raise ValueError(f"Error moving unit: {response.json()}")

        logger.info(f"Unit moved to {selected_sector}")

    response = requests.post(end_turn_url)
    if response.status_code != 200:
        raise ValueError(f"Error ending turn: {response.json()}")

    logger.info("Turn ended")


def visualize_map(sectors: list):
    for row in sectors:
        for sector in row:
            if sector is None:
                print("F", end=",")
            elif not sector:
                print(" ", end=",")
            else:
                print(sector[0]["type"][0], end=",")
        print()


def main():
    game_id = create_game("example")
    team_1_id = create_team(game_id, "Team 1")
    team_2_id = create_team(game_id, "Team 2")
    start_game(game_id)

    game_info = get_game_info(game_id)
    first_team = game_info["activeTeamId"]
    other_team = team_2_id if first_team == team_1_id else team_1_id

    for i in range(5):
        logger.debug("================================")
        perform_turn(game_id, first_team)
        logger.debug("================================")
        logger.debug("================================")
        perform_turn(game_id, other_team)
        logger.debug("================================")


if __name__ == "__main__":
    main()
