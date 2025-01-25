require "test_helper"

class BaseMaterializedViewTest < ActiveSupport::TestCase
  # For the test use a model that inherits from BaseMaterializedView
  MODEL = DamageStat

  test "readonly materialized view" do
    assert MODEL.readonly?, "Materialized views should be readonly"
  end

  test "refresh materialized view" do
    assert_nothing_raised do
      MODEL.refresh
    end
  end

  test "to_table returns a string" do
    create_list(:stat, 5, created_at: Time.zone.now)
    MODEL.refresh

    data = MODEL.limit(5).to_a
    headers = MODEL::HEADERS
    time_filter = 'all_time'
    sort_by = 'steam_id'

    assert MODEL.send(:to_table, data: data, headers: headers, time_filter: time_filter, sort_by: sort_by).is_a?(String)
  end
end
