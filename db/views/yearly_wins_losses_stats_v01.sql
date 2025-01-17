SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  SUM(stats.win) AS total_wins,
  SUM(stats.lose) AS total_losses,
  CAST(EXTRACT(YEAR FROM stats.created_at) AS INT) AS year
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id,
  players.steam_id,
  EXTRACT(YEAR FROM stats.created_at);
