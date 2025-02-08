SELECT
  players.id AS id,
  players.name AS name,
  players.steam_id AS steam_id,
  SUM(stats.win) AS total_wins,
  SUM(stats.lose) AS total_losses
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id, players.steam_id
ORDER BY
  total_wins DESC;
