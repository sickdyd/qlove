SELECT
  players.id AS player_id,
  players.name AS name,
  players.steam_id AS steam_id,
  SUM(accuracy) AS accuracy,
  SUM(assists) AS assists,
  SUM(captures) AS captures,
  SUM(combokill) AS combokill,
  SUM(defends) AS defends,
  SUM(excellent) AS excellent,
  SUM(firstfrag) AS firstfrag,
  SUM(headshot) AS headshot,
  SUM(humiliation) AS humiliation,
  SUM(impressive) AS impressive,
  SUM(midair) AS midair,
  SUM(perfect) AS perfect,
  SUM(perforated) AS perforated,
  SUM(quadgod) AS quadgod,
  SUM(rampage) AS rampage,
  SUM(revenge) AS revenge
FROM
  stats
JOIN
  players ON players.id = stats.player_id
GROUP BY
  players.id, players.steam_id;
