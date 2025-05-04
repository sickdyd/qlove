SELECT
  row_number() OVER () AS id,
  players.id AS player_id,
  players.name AS name,
  players.steam_id AS steam_id,
  SUM(stats.play_time) AS total_play_time
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id, players.steam_id
ORDER BY
  total_play_time DESC;
