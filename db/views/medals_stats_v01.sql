SELECT
  players.id AS player_id,
  players.name AS player_name,
  players.steam_id AS steam_id,
  stats.created_at AS created_at,
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
  SUM(medals.revenge) AS revenge
FROM
  stats
JOIN
  players ON players.id = stats.player_id
JOIN
  medals ON stats.id = medals.stat_id
GROUP BY
  players.id, players.steam_id;
