module CommonParamsDefaults
  extend ActiveSupport::Concern

  DEFAULTS = {
      time_filter: 'day',
      timezone: TimeFilterable::DEFAULT_TIMEZONE,
      limit: ValidateCommonParams::DEFAULT_RESULTS_LIMIT,
      formatted_table: false,
      year: Time.current.in_time_zone(TimeFilterable::DEFAULT_TIMEZONE).year
    }
end
