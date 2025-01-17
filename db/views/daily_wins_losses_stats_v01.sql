SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  SUM(stats.win) AS total_wins,
  SUM(stats.lose) AS total_losses
FROM
  stats
JOIN
  players ON players.id = stats.player_id
WHERE
  stats.created_at >= date_trunc('day', NOW())
GROUP BY
  players.id, players.steam_id;
