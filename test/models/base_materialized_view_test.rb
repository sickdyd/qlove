require "test_helper"

class BaseMaterializedViewTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "readonly materialized view" do
    assert DamageStat.readonly?, "Materialized views should be readonly"
  end

  test "refresh materialized view" do
    assert_nothing_raised do
      DamageStat.refresh
    end
  end

  test "to_table returns a string" do
    create_list(:stat, 5, created_at: Time.zone.now)
    DamageStat.refresh

    data = DamageStat.limit(5).to_a
    headers = DamageStat::HEADERS
    time_filter = 'day'
    sort_by = DamageStat::TOTAL_DAMAGE_DEALT_COLUMN

    assert DamageStat.send(:to_table, data: data, headers: headers, time_filter: time_filter, sort_by: sort_by).is_a?(String)
  end
end
