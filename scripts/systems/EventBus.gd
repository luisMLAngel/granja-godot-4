extends Node

# ── Tiempo ──────────────────────────────────────────────────
signal started_day(day: int)
signal started_night(day: int)
signal hour_changed(hour: float)
signal minute_changed(minute: float)

# ── Energía Vital ────────────────────────────────────────────
signal energy_changed(actual: float, maximo: float)
signal energy_depleted()

# ── Tiles / Farming ──────────────────────────────────────────
signal tile_selected(tile_pos: Vector2i, tile_data: Dictionary)
signal tile_action_executed(tile_pos: Vector2i, action: String, datos: Dictionary)
signal crop_harvested(tile_pos: Vector2i, item_id: String, cantidad: int)

# ── Inventario ───────────────────────────────────────────────
signal item_added(item_id: String, cantidad: int)
signal item_removed(item_id: String, cantidad: int)

# ── Zonas ────────────────────────────────────────────────────
signal zone_unlocked(zone_id: String)
signal zone_changed(zone_id: String)

# ── Historia ─────────────────────────────────────────────────
signal fragment_discovered(fragment_id: String)
signal story_flag_changed(flag: String, valor: bool)

# ── Diálogos ─────────────────────────────────────────────────
signal dialogue_started(npc_id: String)
signal dialogue_finished(npc_id: String)

# ── Combate ──────────────────────────────────────────────────
signal player_damaged(cantidad: float)
signal enemy_killed(enemy_id: String, posicion: Vector2)

# ── Interacción ──────────────────────────────────────────────
signal interaction_prompt_show(data: InteractionData)
signal interaction_prompt_hide()