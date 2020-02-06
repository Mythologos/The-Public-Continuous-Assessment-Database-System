class KnowledgeTopic < ApplicationRecord
  self.primary_key = :kt_id

  has_many :instructions, foreign_key: :kt_id
  has_many :courses, through: :instructions

  has_many :question_topic_mappings, foreign_key: :kt_id
  has_many :rrk_questions, through: :question_topic_mappings

  scope :active, -> { where(active_topic?: true) }

  # TODO: move these?
  @kt_id_column = 0
  @sheet_index = 1
  @kt_area_column = 1
  @kt_unit_column = 2
  @kt_name_column = 3
  @year_added_column = 4
  @in_use_column = 5

  # This method uses the Mapping file, a .xlsx file, to fill the Knowledge Topics
  # relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)

    # This index starts at 1 to avoid the header line.
    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      kt_id = current_row[@kt_id_column].to_i
      if KnowledgeTopic.by_primary_key(kt_id).present?
        if current_row[@in_use_column] == 'x' && KnowledgeTopic.by_primary_key(kt_id).active.present?
          KnowledgeTopic.by_primary_key(kt_id).update(active_topic?: false)
        end
      else
        KnowledgeTopic.create!(attributes = { kt_id: kt_id,
                                              kt_name: current_row[@kt_name_column],
                                              kt_area: current_row[@kt_area_column],
                                              kt_unit: current_row[@kt_unit_column],
                                              year_added: get_year(current_row[@year_added_column]) })
      end
      index += 1
    end
  end
  
  private

  # This function takes a year_cell, an integer,
  # and returns either said year_cell if it is present
  # or the current year if not.
  # params: a year (year_cell)--an integer.
  # return: an integer representing a year.
  def self.get_year(year_cell)
    year_cell.present? ? year_cell : Time.current.year
  end

  # This method serves as a shortcut with find_by to query the primary key.
  # While not directly needed for KTs, it may be useful for unifying method calls
  # with other Models.
  # params: an integer KT ID (id).
  # return: an ActiveRecord object corresponding to the primary key given.
  def self.by_primary_key(id)
    find_by(kt_id: id)
  end
end