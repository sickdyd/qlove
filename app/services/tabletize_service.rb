class TabletizeService
  MIN_COLUMN_WIDTH = 3

  def initialize(title:, headers:, data:)
    @title = title
    @headers = headers.map(&:to_sym)
    @data = data
  end

  def strip_formatting(string)
    string.gsub(/\^([0-9]|\^)/, "") if string
  end

  def truncate_name(name)
    stripped_name = strip_formatting(name || "Unknown")
    stripped_name.length > 15 ? stripped_name[0...15] : stripped_name
  end

  def rows
    @data.each_with_index.map do |player, index|
      [ index + 1 ] + @headers.map do |header|
        value = player[header]
        if header == :player_name
          value = truncate_name(value)
        else
          if value === 0 || value.nil?
            value = "-"
          end
        end
        value
      end
    end
  end

  def formatted_headers
    [ "#" ] + @headers.map { |header| header.to_s.split("_").map(&:upcase).join(" ") }
  end

  def table
    rows_data = rows
    headers_data = formatted_headers
    return "No data to display." if headers_data.empty? || rows_data.empty?

    max_lengths = headers_data.map { |header| [ header.length, MIN_COLUMN_WIDTH ].max }
    rows_data.each do |row|
      row.each_with_index do |cell, i|
        width = Unicode::DisplayWidth.of(strip_formatting(cell.to_s))
        max_lengths[i] = [ max_lengths[i], width ].max
      end
    end

    header_line = "| " + headers_data.each_with_index.map { |header, i| header.ljust(max_lengths[i]) }.join(" | ") + " |"

    separator_line = "+-" + max_lengths.map { |length| "-" * length }.join("-+-") + "-+"

    row_lines = rows_data.map do |row|
      "| " + row.each_with_index.map do |cell, i|
        formatted_cell = strip_formatting(cell.to_s)
        width = Unicode::DisplayWidth.of(formatted_cell)
        formatted_cell + " " * (max_lengths[i] - width)
      end.join(" | ") + " |"
    end

    title_line = if @title
      total_table_width = separator_line.length
      centered_title = @title.center(total_table_width - 2)
      "+#{"-" * (total_table_width - 2)}+\n|#{centered_title}|\n#{separator_line}\n"
    else
      ""
    end

    title_line + [ header_line, separator_line, *row_lines, separator_line ].join("\n")
  end
end
