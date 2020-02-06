class RrkQuestion < ApplicationRecord
  self.primary_key = :question_id

  has_many :answers, foreign_key: :question_id
  has_many :students, through: :answers

  belongs_to :rrk_quiz, foreign_key: %i[course_id course_discipline rrk_quiz_version]

  has_many :question_topic_mappings, foreign_key: :question_id
  has_many :knowledge_topics, through: :question_topic_mappings

  belongs_to :taxonomy, foreign_key: :taxonomic_id

  scope :by_text, ->(text) { where(question_text: text) }
  scope :by_semester, lambda { |discipline, id, quiz_version|
    where(course_id: id,
          course_discipline: discipline,
          rrk_quiz_version: quiz_version)
  }

  # TODO: move this?
  @sheet_index = 0
  @taxonomic_id_column = 1
  @question_text_column = 2
  @course_discipline_column = 3
  @course_id_column = 4
  @rrk_quiz_version_column = 5
  @correct_answer_column = 6
  @incorrect_answer_1_column = 7
  @incorrect_answer_2_column = 8
  @incorrect_answer_3_column = 9
  @incorrect_answer_4_column = 10

  # This method uses the RRK Question Listing file, a .xlsx file,
  # to fill the RRK Questions relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # This index starts at 1 to avoid the Header line.

    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      RrkQuestion.find_or_create_by!(attributes = { correct_answer:
                                                        current_row[@correct_answer_column],
                                                    course_id:
                                                        current_row[@course_id_column],
                                                    course_discipline:
                                                        current_row[@course_discipline_column],
                                                    incorrect_answer_1:
                                                        current_row[@incorrect_answer_1_column],
                                                    incorrect_answer_2:
                                                        evaluate_answer(current_row[@incorrect_answer_2_column]),
                                                    incorrect_answer_3:
                                                        evaluate_answer(current_row[@incorrect_answer_3_column]),
                                                    incorrect_answer_4:
                                                        evaluate_answer(current_row[@incorrect_answer_4_column]),
                                                    rrk_quiz_version:
                                                        current_row[@rrk_quiz_version_column],
                                                    question_text:
                                                        current_row[@question_text_column],
                                                    taxonomic_id:
                                                        current_row[@taxonomic_id_column] })
      index += 1
    end
  end

  # This method serves as a shortcut with find_by to query the primary key.
  # While not directly needed for RRK Questions,
  # it may be useful for unifying method calls with other Models.
  # params: an integer RRK Question ID (quid).
  # return: an ActiveRecord object corresponding to the primary key given.
  def self.by_primary_key(quid)
    find_by(question_id: quid)
  end

  private

  # This predicate function determines whether an answer exists or not.
  # It returns nil if the answer isn't present; otherwise, it returns the answer.
  # params: an answer (which is a string).
  # return: either the answer or nil depending on whether answer is present.
  def self.evaluate_answer(answer)
    answer.present? ? answer : nil
  end
end