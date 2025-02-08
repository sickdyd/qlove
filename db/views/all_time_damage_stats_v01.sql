SELECT
  players.id AS id,
  players.name AS name,
  players.steam_id AS steam_id,
  SUM(stats.damage_dealt) AS total_damage_dealt,
  SUM(stats.damage_taken) AS total_damage_taken
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id, players.steam_id
ORDER BY
  total_damage_dealt DESC;
