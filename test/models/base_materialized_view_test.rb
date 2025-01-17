require "test_helper"

class BaseMaterializedViewTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  daily_damage_stats_instance = DamageStats::DailyDamageStats

  test "readonly materialized view" do
    assert daily_damage_stats_instance.readonly?, "Materialized views should be readonly"
  end

  test "refresh materialized view" do
    assert_nothing_raised do
      daily_damage_stats_instance.refresh
    end
  end

  test "validate year does not raise for valid year" do
    assert_nothing_raised do
      daily_damage_stats_instance.send(:validate_year, time_filter: 'year', year: 2021)
    end
  end

  test "validate year raises for invalid year" do
    assert_raise ArgumentError do
      daily_damage_stats_instance.send(:validate_year, time_filter: 'year', year: 0)
    end
  end

  test "start time" do
    assert daily_damage_stats_instance.send(:start_time, time_filter: 'day', timezone: 'UTC').is_a?(Time)
  end

  test "to_table returns a string" do
    create_list(:stat, 5, created_at: Time.zone.now)
    DamageStats::DailyDamageStats.refresh

    data = daily_damage_stats_instance.limit(5).to_a
    headers = DamageStats::HEADERS
    time_filter = 'day'
    sort_by = DamageStats::TOTAL_DAMAGE_DEALT_COLUMN

    assert daily_damage_stats_instance.send(:to_table, data: data, headers: headers, time_filter: time_filter, sort_by: sort_by).is_a?(String)
  end
end
