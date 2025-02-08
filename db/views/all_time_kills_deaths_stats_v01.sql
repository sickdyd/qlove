SELECT
  players.id AS id,
  players.name AS name,
  players.steam_id AS steam_id,
  SUM(stats.kills) AS total_kills,
  SUM(stats.deaths) AS total_deaths,
  CASE
    WHEN SUM(stats.deaths) = 0 THEN NULL
    ELSE ROUND(SUM(stats.kills)::numeric / SUM(stats.deaths), 2)
  END AS kill_death_ratio
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id, players.steam_id
ORDER BY
  total_kills DESC;
