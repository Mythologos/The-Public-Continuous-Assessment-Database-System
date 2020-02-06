class StudentLearningOutcome < ApplicationRecord
  self.primary_key = :slo_id

  has_many :kt_slo_mappings, foreign_key: :slo_id
  has_many :knowledge_topics, through: :kt_slo_mappings

  scope :active, -> { where(active_outcome?: true) }

  # TODO: move these?
  @sheet_index = 5

  @slo_id_column = 0
  @slo_name_column = 1
  @slo_description_column = 2
  @accreditation_body_column = 3
  @year_added_column = 4
  @activity_column = 5

  # This method uses the Mapping file, a .xlsx file, to fill the
  # Student Learning Outcomes relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # This index begins at 1 to avoid the header line in the file.
    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      slo_id = current_row[@slo_id_column]
      if StudentLearningOutcome.by_primary_key(slo_id).present?
        if current_row[@activity_column] == 'x' && StudentLearningOutcome.active
                                                                         .by_primary_key(slo_id)
                                                                         .present?
          StudentLearningOutcome.by_primary_key(slo_id)
                                .update(active_outcome?: false)
        end
      else
        StudentLearningOutcome.create!(accreditation_body: current_row[@accreditation_body_column],
                                       slo_description: get_description(current_row[@slo_description_column]),
                                       slo_id: slo_id,
                                       slo_name: current_row[@slo_name_column],
                                       year_added: get_year(current_row[@year_added_column]))
      end
      index += 1
    end
  end

  private

  # This function returns a given year or the current year.
  # It does so depending on the presence of the given year.
  # params: a cell of the .xlsx file containing the year (year_cell)--an integer.
  # return: the year (year_cell) or the current year (both are integers).
  def self.get_year(year_cell)
    year_cell.present? ? year_cell : Time.current.year
  end

  # This function returns a 's description if it is present.
  # Otherwise, it returns a default description.
  # params: a cell of the .xlsx file containing the description--a string.
  # return: the description_cell's contents or a default description.
  def self.get_description(description_cell)
    description_cell.present? ? description_cell : 'No description provided.'
  end

  # This method serves as a shortcut with find_by to query the primary key.
  # While not directly needed for SLOs, it may be useful for unifying method calls
  # with other Models.
  # params: an integer SLO ID (id).
  # return: an ActiveRecord object corresponding to the primary key given.
  def self.by_primary_key(id)
    find_by(slo_id: id)
  end
end