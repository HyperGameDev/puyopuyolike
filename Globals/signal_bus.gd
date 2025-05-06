extends Node
@warning_ignore_start("unused_signal")

signal restart
signal change_level(level_to_change_to: int)
signal any_transition_ended(level_changed_from: int)

signal spawn_garbage
