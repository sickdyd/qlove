SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  weapons.name AS weapon_name,
  SUM(weapons.shots) AS total_shots,
  SUM(weapons.hits) AS total_hits,
  stats.created_at AS created_at
FROM
  weapons
JOIN
  stats ON weapons.stat_id = stats.id
JOIN
  players ON stats.player_id = players.id
GROUP BY
  players.id, players.steam_id, weapons.name, stats.created_at;
