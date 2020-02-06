class Answer < ApplicationRecord
  require 'fnv'

  self.primary_keys = :student_id, :question_id

  belongs_to :rrk_question, foreign_key: :question_id
  belongs_to :student, foreign_key: :student_id
  belongs_to :course_section, foreign_key: %i[crn section_number year_offered]

  scope :correct, -> { where(correct?: true) }
  scope :by_enrollment, lambda { |crn, student_id, year|
    where(crn: crn, student_id: student_id, year_offered: year)
  }

  # TODO: move these?
  @header_row_index = 0
  @first_data_row_index = 1
  @crn_column = 2
  @student_name_column = 0
  @section_identifier_column = 2
  @student_id_column = 6
  @first_question_score_column = 8
  @first_answer_score_column = 9
  @semester_year_slice = 0
  @course_discipline_slice = 1
  @course_id_slice = 2
  @section_number_slice = 3

  # This method uses the Student Analysis files from Canvas as .xlsx files,
  # alongside some supplementary data, to fill the Answers relation with
  # appropriate tuples.
  # params: a .xlsx file (xlsx_file) and an integer year (y_off).
  def self.upload(xlsx_file, y_off)


    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    crn = get_crn(processed_fileset.sheets.first.rows[@first_data_row_index][@crn_column].split('-'))
    section = CourseSection.by_section_group(crn, y_off).first
    questions = RrkQuestion.by_semester(section.course_discipline,
                                        section.course_id,
                                        section.rrk_quiz_version)
                           .order(:question_id)
                           .pluck(:question_id)

    # The following item holds tuples that don't have an ID that matches.
    invalid_id_list = []

    # The following item holds what counts as full points for a question,
    # as this value may vary from quiz to quiz.
    full_point_value = processed_fileset.sheets.first.rows[@header_row_index][@first_answer_score_column].to_i

    # This index starts at 1 to avoid the header line.
    index = 1
    while index < processed_fileset.sheets.first.rows.size
      current_row = processed_fileset.sheets.first.rows[index]
      student_id = current_row[@student_id_column]
      if Student.by_valid_id(student_id, current_row[@student_name_column]).present?
        section_identifiers = current_row[@section_identifier_column].split('-')
        crn = get_crn(section_identifiers)
        section_number = section_identifiers[@section_number_slice].to_i
        # This variable tallies the number of correct answers for a student.
        num_correct = 0
        questions.each_with_index do |question_id, id_index|
          answer_index = @first_question_score_column + (2 * id_index)
          correctness = correct_answer?(current_row, answer_index + 1, full_point_value)
          if correctness
            num_correct += 1
          end
          Answer.find_or_create_by!(attributes = { answer_given: get_answer(question_id, current_row, answer_index),
                                                   correct?: correctness,
                                                   crn: crn,
                                                   section_number: section_number,
                                                   student_id: student_id,
                                                   question_id: question_id,
                                                   year_offered: y_off })
          if (questions.size - 1) == id_index
            Student.find(student_id)
                   .update(research_consent?: consent_given?(current_row[answer_index + 2]))
            enrollment_to_update = Enrollment.find_by(crn: crn, section_number: section_number,
                                                      student_id: student_id, year_offered: y_off)
            enrollment_to_update.update(rrk_quiz_score: num_correct.to_f / questions.size.to_f) if enrollment_to_update.present?
          end
        end
      else
        invalid_id_list.append(current_row[@student_name_column])
      end
      index += 1
    end
    invalid_id_list
  end

  # TODO: have method signal new page to signal that a person has already taken the quiz,
  # avoiding the error and immediately pointing out the cause?

  private

  # This method determines whether a given answer is correct.
  # params: a given row from the Student Analysis file (answer_row)
  # and the index for the given answer's correctness (answer_index).
  # return: a boolean of whether the answer is correct or not.
  def self.correct_answer?(answer_row, answer_index, full_point_value)
    answer_row[answer_index].to_i == full_point_value
  end

  # This method retrieves a student's answer and
  # removes any corrupted text (e.g. mojibake) from the text.
  # params: a question ID integer (question_id),
  # a given row from the Student Analysis file (answer_row),
  # and the index for the given answer's text (answer_index).
  # return: the answer given, if it is present, or a default value.
  def self.get_answer(question_id, answer_row, answer_index)
    given_answer = 'Unanswered'
    if answer_row[answer_index].present?
      given_answer = answer_row[answer_index].to_s
      if given_answer.include?('Â')
        given_answer = given_answer.gsub('Â', '')
                                   .gsub(160.chr('UTF-8'), ' ')
                                   .gsub(' ', '')
        possible_answers = RrkQuestion.by_primary_key(question_id)
        possible_answers = [possible_answers.correct_answer,
                            possible_answers.incorrect_answer_1,
                            possible_answers.incorrect_answer_2,
                            possible_answers.incorrect_answer_3,
                            possible_answers.incorrect_answer_4].keep_if(&:present?)
        possible_answers.each do |answer|
          if given_answer == answer.gsub('> ', '').gsub('< ', '').gsub(' ', '')
            given_answer = answer
            break
          end
        end
      end
    end
    given_answer
  end

  # This method retrieves the CRN for a given section based on a larger key for CourseSections.
  # params: an array of CourseSection data derived from the Answer document (section_data)
  # return: a CRN that aligns with all of the given data.
  def self.get_crn(section_data)
    CourseSection.where(course_discipline: section_data[@course_discipline_slice],
                        course_id: section_data[@course_id_slice].to_i,
                        section_number: section_data[@section_number_slice].to_i,
                        semester_offered: section_data[@semester_year_slice][4..5].to_i,
                        year_offered: section_data[@semester_year_slice][0..3].to_i)
                 .first
                 .crn
  end

  # This method determines whether a student gave consent
  # for their answers to be used in research.
  # params: a cell containing a student's answer to a consent question
  # as a string (consent_cell).
  # a Boolean of whether the student gave consent to be included in research.
  def self.consent_given?(consent_cell)
    consent_cell == 'Yes, and I am 18 years of age or older.'
  end

  # This method serves as a shortcut with find_by to query the primary key.
  # params: an integer CRN (crn), an integer section number (section),
  # an integer Student ID (student_id), and an integer year (year).
  # return: an ActiveRecord object corresponding to the primary key given.
  def self.by_primary_key(crn, section, student_id, year)
    find_by(crn: crn, section_number: section,
            student_id: student_id, year_offered: year)
  end
end