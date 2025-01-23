SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  stats.created_at AS created_at,
  SUM(stats.damage_dealt) AS total_damage_dealt,
  SUM(stats.damage_taken) AS total_damage_taken
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id, players.steam_id;
