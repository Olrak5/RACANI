from typing import Dict, Set
from uuid import uuid4

from pydantic import Field

from consts import TEAMS_NEUTRAL_ID
from entities.dynamic.buildings.capital import Capital
from simulation.consts import GameStates
from simulation.history import History
from simulation.map import Map
from simulation.team import Team
from utils.logger import get_logger
from utils.root_model import RootModel

logger = get_logger("game")


class Game(RootModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    map: Map
    teams: Dict[str, Team] = Field(default_factory=dict)
    history: History = History()
    state: GameStates = GameStates.BEFORE_START
    activeTeamId: str = TEAMS_NEUTRAL_ID
    movedUnits: Set[str] = Field(default_factory=set)
    winningTeamId: str = TEAMS_NEUTRAL_ID

    @staticmethod
    def new_game(map_path: str, **__) -> "Game":
        logger.info(f"Creating new game with map: {map_path}")
        _map = Map.from_file(map_path)
        game = Game(map=_map)
        logger.debug(f"Created game with id: {game.id}")
        return game

    def get_active_team(self) -> Team:
        return self.teams[self.activeTeamId]

    def register_team(self, name: str) -> Team:
        if self.state != GameStates.BEFORE_START:
            raise ValueError(
                f"Game is in bad state to register team ({self.state})"
            )

        logger.info(f"Registering new team: {name}")
        team = Team(name=name)
        self.teams[team.id] = team
        logger.debug(f"Registered team with id: {team.id}")
        return team

    def start(self) -> None:
        if self.state != GameStates.BEFORE_START:
            raise ValueError(f"Game is in bad state to start ({self.state})")

        logger.info(f"Starting game ({self.id})")
        self.state = GameStates.IN_PROGRESS
        self.activeTeamId = list(self.teams.keys())[0]

        logger.debug(f"Active team: {self.activeTeamId}")

        self._mark_capitals()

        logger.debug("Executing on_turn_start for the first time")
        self._on_turn_start()

        logger.info(f"Game started with active team: {self.activeTeamId}")

    def end_turn(self) -> None:
        logger.info(f"Ending turn for team: {self.activeTeamId}")

        if winning_team := self._has_ended():
            logger.info(f"Game has ended, winning team: {winning_team}")
            self.stop(winning_team)
            return

        logger.debug("Executing on_turn_end")
        self._on_turn_end()

        self.movedUnits = set()

        self.activeTeamId = self._get_next_team_id()
        logger.info(f"Starting turn for team: {self.activeTeamId}")

        logger.debug("Executing on_turn_start")
        self._on_turn_start()

    def stop(self, winning_team_id: str = TEAMS_NEUTRAL_ID) -> None:
        self.state = GameStates.FINISHED
        self.activeTeamId = TEAMS_NEUTRAL_ID
        self.winningTeamId = winning_team_id

    def _mark_capitals(self):
        logger.info("Marking capitals")

        capitals: Set[Capital] = {
            entity for entity in self.map.get_entities()
            if isinstance(entity, Capital)
        }

        if len(capitals) != len(self.teams):
            raise ValueError(
                "Number of capitals in map must be equal to number of teams"
            )

        for team, capital in zip(self.teams.values(), capitals):
            capital.teamId = team.id

        self.map.update_entities(capitals)

    def _get_next_team_id(self) -> str:
        team_ids = list(self.teams.keys())
        current_team_index = team_ids.index(self.activeTeamId)
        next_team_index = (current_team_index + 1) % len(team_ids)
        return team_ids[next_team_index]

    def _has_ended(self) -> str:
        undefeated_teams = []

        for team in self.teams.values():
            if not team.isDefeated:
                undefeated_teams.append(team.id)

        if len(undefeated_teams) == 1:
            return undefeated_teams[0]

        return ""

    def _on_turn_start(self):
        for entity in self.map.get_entities_by_team(self.activeTeamId):
            logger.debug(
                f"Executing on_turn_start for entity: "
                f"({entity.type}, {entity.id})"
            )
            entity.on_turn_start(self)

        logger.debug("Recalculating visible area")
        self.teams[self.activeTeamId].recalculate_visible_area(self.map)

    def _on_turn_end(self):
        for entity in self.map.get_entities_by_team(self.activeTeamId):
            logger.debug(
                f"Executing on_turn_end for entity: "
                f"({entity.type}, {entity.id})"
            )
            entity.on_turn_end(self)

        logger.debug("Recalculating visible area")
        self.teams[self.activeTeamId].recalculate_visible_area(self.map)
