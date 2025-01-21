SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  SUM(medals.accuracy) AS accuracy,
  SUM(medals.assists) AS assists,
  SUM(medals.captures) AS captures,
  SUM(medals.combokill) AS combokill,
  SUM(medals.defends) AS defends,
  SUM(medals.excellent) AS excellent,
  SUM(medals.firstfrag) AS firstfrag,
  SUM(medals.headshot) AS headshot,
  SUM(medals.humiliation) AS humiliation,
  SUM(medals.impressive) AS impressive,
  SUM(medals.midair) AS midair,
  SUM(medals.perfect) AS perfect,
  SUM(medals.perforated) AS perforated,
  SUM(medals.quadgod) AS quadgod,
  SUM(medals.rampage) AS rampage,
  SUM(medals.revenge) AS revenge,
  CAST(EXTRACT(YEAR FROM stats.created_at) AS INT) AS year
FROM
  stats
JOIN
  players ON players.id = stats.player_id
JOIN
  medals ON stats.id = medals.stat_id
WHERE
  stats.created_at >= date_trunc('year', NOW())
GROUP BY
  players.id,
  players.steam_id,
  EXTRACT(YEAR FROM stats.created_at);
