require "chinese_pinyin"

class ChineseIdeogramsReplacerService
  def self.sanitize(data)
    data.map do |row|
      if contains_ideogram?(row.name)
        row.name = row.name.gsub(/\^([0-9]|\^)/, "")
        row.name = Pinyin.t(row.name, splitter: " ", tone: false).squeeze(" ").strip
      end

      row
    end
  end

  def self.contains_ideogram?(string)
    !!(string =~ /[\p{Han}]/)
  end
end
