class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # This method takes a year-semester cell from a spreadsheet.
  # It should be of the format: "YYYYSS".
  # It extracts the year from this spreadsheet.
  # params: a year-semester cell of the above format.
  # return: the year contained with the input cell.
  def self.get_year(year_cell)
    year_cell.to_s.slice(0..3).to_i
  end
end
