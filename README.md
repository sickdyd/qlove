# QLOVE

## What is it?

Shows daily, weekly, monthly and all time stats for Quake players in a formatted table.

<img width="507" alt="Screenshot 2025-04-27 at 18 39 45" src="https://github.com/user-attachments/assets/38388783-4767-4454-af87-edcece5e88d5" />

<img width="437" alt="Screenshot 2025-04-27 at 18 40 12" src="https://github.com/user-attachments/assets/28051f0f-d509-470c-a6c0-ccf78d9736ce" />

<img width="438" alt="Screenshot 2025-04-27 at 18 39 58" src="https://github.com/user-attachments/assets/e9fb83fc-03d3-46f7-903f-fa2b30a29f4c" />

<img width="519" alt="Screenshot 2025-04-27 at 18 40 21" src="https://github.com/user-attachments/assets/c725df9e-83fd-42e1-89f3-730f95813cc0" />

It's a service that starts a ZeroMQ listener pointed to a Quake Live server queue and tracks the fed data.

Works with the minqlx plugin [here](https://github.com/sickdyd/minqlx-plugins/blob/feature/leaderboards/leaderboards.py).

## Endpoints

- `GET /api/v1/leaderboards/accuracy`
- `GET /api/v1/leaderboards/kills`
- `GET /api/v1/leaderboards/deaths`
- `GET /api/v1/leaderboards/damage`
- `GET /api/v1/leaderboards/damage_dealt`
- `GET /api/v1/leaderboards/damage_taken`
- `GET /api/v1/leaderboards/wins`
- `GET /api/v1/leaderboards/losses`
- `GET /api/v1/leaderboards/medals`
- `GET /api/v1/leaderboards/stats`
- `GET /api/v1/leaderboards/best`
- `GET /api/v1/leaderboards/best_players`
- `GET /api/v1/leaderboards/kills_deaths_ratio`

## Common Query Parameters

- `time_filter=day|week|month|year|all_time`
- `formatted_table=true`
- `limit=N`
- `steam_id=STEAM_ID` (used mainly for `stats`, `accuracy`)
- `weapons=bfg,rocket,railgun,plasma,shotgun,grenade,lightning,machinegun,hmg,nailgun,chaingun,proxmine,gauntlet,other_weapon`
- `medals=accuracy,assists,captures,combokill,defends,excellent,firstfrag,headshot,humiliation,impressive,midair,perfect,perforated,quadgod,rampage,revenge`
- `year=YYYY`

## To start the server

```sh
rails s
```

## Samples

```sh
# Get kills leaderboard (week)
curl "http://localhost:3000/api/v1/leaderboards/kills?time_filter=week&formatted_table=true" | jq -r '.data'

# Get damage dealt (month)
curl "http://localhost:3000/api/v1/leaderboards/damage_dealt?time_filter=month&formatted_table=true" | jq -r '.data'

# Get accuracy leaderboard for specific weapons
curl "http://localhost:3000/api/v1/leaderboards/accuracy?weapons=rocket,railgun&formatted_table=true&time_filter=all_time" | jq -r '.data'

# Get medals leaderboard filtered by medal types
curl "http://localhost:3000/api/v1/leaderboards/medals?medals=accuracy,excellent,humiliation&time_filter=all_time&formatted_table=true" | jq -r '.data'

# Get player stats by steam_id
curl "http://localhost:3000/api/v1/leaderboards/stats?steam_id=76561197998172344&time_filter=month&formatted_table=true" | jq -r '.data'
```
