SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  SUM(stats.kills) AS total_kills,
  SUM(stats.deaths) AS total_deaths,
  CAST(EXTRACT(YEAR FROM stats.created_at) AS INT) AS year,
  CASE
    WHEN SUM(stats.deaths) = 0 THEN NULL 
    ELSE ROUND(SUM(stats.kills)::numeric / SUM(stats.deaths), 2) 
  END AS kills_deaths_ratio
FROM
  stats
JOIN
  players ON players.id = stats.player_id
WHERE
  stats.created_at >= date_trunc('day', NOW())
GROUP BY
  players.id,
  players.steam_id,
  EXTRACT(YEAR FROM stats.created_at);
