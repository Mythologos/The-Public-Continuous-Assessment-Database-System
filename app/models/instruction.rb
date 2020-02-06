class Instruction < ApplicationRecord
  self.primary_keys = :kt_id, :course_id, :course_discipline

  belongs_to :knowledge_topic, foreign_key: :kt_id

  belongs_to :course, foreign_key: %i[course_id course_discipline]

  # TODO: move these?
  @kt_id_column = 0
  @top_row_index = 0
  @sheet_number = 1

  # This method uses the Mapping file, a .xlsx file, to fill the Instructions
  # relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # This index starts at 1 avoids the header in the spreadsheet.
    index = 1
    course_index = 6 + StudentLearningOutcome.active.count
    while index < processed_fileset.sheets[@sheet_number].rows.size
      top_row = processed_fileset.sheets[@sheet_number].rows[@top_row_index]
      current_row = processed_fileset.sheets[@sheet_number].rows[index]
      unless current_row[course_index].blank?
        Instruction.find_or_create_by!(attributes = { course_id: top_row[course_index].slice(4..6).to_i,
                                                      course_discipline: top_row[course_index].slice(0..3),
                                                      kt_id: current_row[@kt_id_column],
                                                      mapping_relationship: current_row[course_index] })
      end
      course_index += 1
      if course_index == top_row.size
        index += 1
        course_index = 6 + StudentLearningOutcome.active.count
      end
    end
  end
end