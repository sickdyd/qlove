class AccuracyStat < BaseMaterializedView
  UNAVAILABLE_ACCURACY = '-'

  ALL_WEAPONS = %w[
    bfg
    chaingun
    gauntlet
    grenade
    hmg
    lightning
    machinegun
    nailgun
    other_weapon
    plasma
    proxmine
    railgun
    rocket
    shotgun
  ].freeze

  SHORTENED_WEAPON_NAMES = {
    'bfg' => 'BFG',
    'chaingun' => 'CG',
    'gauntlet' => 'G',
    'grenade' => 'GL',
    'hmg' => 'HMG',
    'lightning' => 'LG',
    'machinegun' => 'MG',
    'nailgun' => 'NG',
    'other_weapon' => 'OW',
    'plasma' => 'PG',
    'proxmine' => 'PM',
    'railgun' => 'RG',
    'rocket' => 'RL',
    'shotgun' => 'SG'
  }.freeze

  SHORTENED_HEADERS = {
    average_accuracy: 'AVG'
  }.freeze

  AVERAGE_ACCURACY_COLUMN = 'average_accuracy'

  def self.headers(weapons)
    %w[player_name] +  [SHORTENED_HEADERS[:average_accuracy]] + weapons.map{ |weapon| SHORTENED_WEAPON_NAMES[weapon] }
  end
end
