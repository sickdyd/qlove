SELECT
  ROW_NUMBER() OVER (ORDER BY players.id) AS id,
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  SUM(stats.damage_dealt) AS total_damage_dealt,
  SUM(stats.damage_taken) AS total_damage_taken
FROM
  stats
JOIN
  players ON players.id = stats.player_id
WHERE
  stats.created_at >= date_trunc('month', NOW())
GROUP BY
  players.id, players.name, players.steam_id;