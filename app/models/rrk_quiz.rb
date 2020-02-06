class RrkQuiz < ApplicationRecord
  self.primary_keys = :course_id, :course_discipline, :rrk_quiz_version

  has_many :rrk_questions, foreign_key: %i[course_id course_discipline rrk_quiz_version]
  has_many :course_sections, through: :enrollments

  has_many :enrollments, foreign_key: %i[course_id course_discipline rrk_quiz_version]
  has_many :students, through: :enrollments

  scope :active, -> { where(active_quiz?: true) }
  scope :by_course, lambda { |discipline, id|
    where(course_discipline: discipline, course_id: id)
  }

  # TODO: move this?
  @sheet_index = 1

  @course_discipline_column = 0
  @course_id_column = 1
  @rrk_quiz_version_column = 2
  @total_questions_column = 3
  @quiz_creator_column = 4
  @activity_column = 5

  # This method uses the RRK Question Listing file, a .xlsx file, to fill the
  # RRK Quizzes relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # To avoid the header line, the index starts at 1.
    index = 1
    while index < processed_fileset.sheets[@sheet_index].rows.size
      current_row = processed_fileset.sheets[@sheet_index].rows[index]
      discipline = current_row[@course_discipline_column]
      course_id = current_row[@course_id_column].to_i
      quiz_version = current_row[@rrk_quiz_version_column].to_i
      activity_mark = current_row[@activity_column]
      if RrkQuiz.by_primary_key(discipline, course_id, quiz_version).present?
        if RrkQuiz.by_primary_key(discipline, course_id, quiz_version)
                  .active_quiz? && !marked_active?(activity_mark)
          RrkQuiz.by_primary_key(discipline, course_id, quiz_version).active
                 .update(active_quiz?: false)
        end
      else
        latest_quiz = RrkQuiz.by_course(discipline, course_id)
                             .by_latest_version(discipline, course_id)
        if latest_quiz.present? && latest_quiz.first.rrk_quiz_version < quiz_version
          RrkQuiz.by_primary_key(discipline, course_id, latest_quiz.first.rrk_quiz_version)
                 .update(active_quiz?: false)
        end
        RrkQuiz.create_with(discipline, course_id, quiz_version, current_row, activity_mark)
      end
      index += 1
    end
  end

  # This method forms a new RRKQuiz tuple in the database.
  # params: a course discipline String (discipline), a course ID integer (id),
  # an RRK Quiz Version integer (quiz_version), the current Excel sheet row as an Array
  # (current_row), and the cell which states whether a quiz is active or not (marked_active).
  def self.create_with(discipline, id, quiz_version, current_row, activity_mark)
    RrkQuiz.create!(attributes = { course_discipline: discipline,
                                   course_id: id,
                                   rrk_quiz_version: quiz_version,
                                   quiz_creator: current_row[@quiz_creator_column],
                                   total_number_of_questions: current_row[@total_questions_column],
                                   active_quiz?: marked_active?(activity_mark) })
  end

  # This method retrieves the latest version of an RRK Quiz for a given course.
  # params: a course discipline string (discipline) and a course ID integer (id).
  # return: an RRK Quiz Version integer or nil.
  def self.get_latest_version(course_discipline, course_id)
    rrk_version = RrkQuiz.by_course(course_discipline, course_id).active.first
    rrk_version.present? ? rrk_version.rrk_quiz_version : nil
  end

  private

  # This method compares an In_Use cell with the string 'x'.
  # It determines whether a quiz is still in use.
  # param: a String from the In_Use column of the RRK Quiz sheet.
  # return: a Boolean resulting on the equality comparison.
  def self.marked_active?(in_use_cell)
    in_use_cell != 'x'
  end

  # This method queries RRKQuiz as a shortcut for a find_by RRKQuiz's primary key attributes.
  # params: a course discipline string (discipline), a course ID integer (id),
  # and an RRK Quiz Version integer (quiz_version).
  # return: the ActiveRecord object which matches the given primary key (or nil).
  def self.by_primary_key(discipline, id, quiz_version)
    find_by(course_discipline: discipline,
            course_id: id,
            rrk_quiz_version: quiz_version)
  end

  # This method queries RRKQuiz by a course and the latest version of its quiz.
  # params: a course discipline string (discipline) and a course ID integer (id).
  # return: an ActiveRecord object with the highest RRKQuiz version for a given course.
  def self.by_latest_version(discipline, id)
    where(rrk_quiz_version: RrkQuiz.by_course(discipline, id).maximum(:rrk_quiz_version))
  end
end