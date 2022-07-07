extends Node

#signal set_position(pos)
signal set_spawn(origin)
signal respawn()
signal load_level(level)
signal update_level_name(level_name)
signal update_death_count(count)
signal update_player_death_state(dead)
signal add_to_score(score)
signal kill()

var player_deaths: int
