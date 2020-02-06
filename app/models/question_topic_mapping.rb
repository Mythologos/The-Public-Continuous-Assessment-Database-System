class QuestionTopicMapping < ApplicationRecord
  self.primary_keys = :kt_id, :question_id
  belongs_to :knowledge_topic, foreign_key: :kt_id
  belongs_to :rrk_question, foreign_key: :question_id

  # TODO: move this?
  @sheet_index = 0
  @kt_ids_column = 0
  @question_text_column = 2
  @course_discipline_column = 3
  @course_id_column = 4
  @rrk_quiz_version_column = 5

  # This function takes a supplied .xlsx file and uses it to create
  # QuestionTopicMapping tuples.
  # params: a .xlsx file (xlsx_file) of a specific format.
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # This index starts at 1 to avoid the Header line.
    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      processed_row = processed_fileset.sheets[@sheet_index].rows[index]
      q_id = RrkQuestion.by_semester(processed_row[@course_discipline_column],
                                     processed_row[@course_id_column],
                                     processed_row[@rrk_quiz_version_column])
                        .by_text(processed_row[@question_text_column]).first.question_id
      parse_kts(processed_row[@kt_ids_column]).each do |kt|
        QuestionTopicMapping.find_or_create_by(attributes = { kt_id: kt,
                                                              question_id:
                                                                  q_id })
      end
      index += 1
    end
  end

  private

  # This function takes the cell containing KTs and retrieves them,
  # making each KT in the cell into an integer.
  # params: a string containing the KTs.
  # return: an array of integers extracted from the string.
  def self.parse_kts(kt_cell)
    kt_cell.gsub(' ', '').split(',').map(&:to_i)
  end
end
