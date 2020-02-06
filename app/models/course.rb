class Course < ApplicationRecord
  self.primary_keys = :course_id, :course_discipline

  has_many :course_sections, foreign_key: %i[course_id course_discipline]

  has_many :instructions, foreign_key: %i[course_id course_discipline]
  has_many :knowledge_topics, through: :instructions

  # TODO: move these?
  @sheet_index = 7
  @course_discipline_column = 0
  @course_id_column = 1
  @course_title_column = 2
  @prerequisite_discipline_1_column = 3
  @prerequisite_id_1_column = 4
  @prerequisite_discipline_2_column = 5
  @prerequisite_id_2_column = 6
  @auxiliary_discipline_column = 7
  @auxiliary_id_column = 8

  # This method uses the Mapping file, a .xlsx file, to fill the Courses
  # relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # The index begins at 1 to avoid getting data from the header line.
    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      Course.find_or_create_by!(attributes = { course_id:
                                                   current_row[@course_id_column],
                                               course_discipline:
                                                   current_row[@course_discipline_column],
                                               course_title:
                                                   current_row[@course_title_column],
                                               prerequisite_discipline_1:
                                                   current_row[@prerequisite_discipline_1_column],
                                               prerequisite_id_1:
                                                   current_row[@prerequisite_id_1_column],
                                               prerequisite_discipline_2:
                                                   current_row[@prerequisite_discipline_2_column],
                                               prerequisite_id_2:
                                                   current_row[@prerequisite_id_2_column],
                                               auxiliary_course_discipline:
                                                   current_row[@auxiliary_discipline_column],
                                               auxiliary_course_id:
                                                   current_row[@auxiliary_id_column] })
      index += 1
    end
  end
end
