class Student < ApplicationRecord
  require 'fnv'

  self.primary_key = :student_id

  has_many :answers, foreign_key: :student_id
  has_many :rrk_questions, through: :answers

  has_many :enrollments, foreign_key: :student_id
  has_many :course_sections, through: :enrollments

  # TODO: move these?
  @student_id_column = 5
  @last_name_column = 6
  @first_name_column = 7
  @preferred_name_column = 8
  @sat_math_column = 10
  @sat_column = 11
  @act_column = 12
  @act_math_column = 13
  @math_placement_column = 14
  @ethnicity_column = 15
  @gender_column = 16

  @enrollments_student_id_column = 2
  @enrollments_last_name_column = 3
  @enrollments_first_name_column = 4
  @enrollments_preferred_name_column = 5

  # This method uses the Student Data file, a .xlsx file,
  # to fill the Students relation with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  # TODO: this will need various update procedures--e.g. for student degrees, name changes, rrk quiz scores, and course grades
  def self.upload(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)

    index = 6

    while index < processed_fileset.sheets.first.rows.size
      current_row = processed_fileset.sheets.first.rows[index]
      Student.find_or_create_by!(act_math_score: retrieve_act_math(current_row),
                                 act_score: retrieve_act(current_row),
                                 ethnicity: current_row[@ethnicity_column],
                                 gender: current_row[@gender_column],
                                 math_placement_level: current_row[@math_placement_column],
                                 nh_value: Fnv::Hash.fnv_1a(retrieve_name(current_row),
                                                            size: 32),
                                 research_consent?: false,
                                 sat_math_score: retrieve_sat_math(current_row),
                                 sat_score: retrieve_sat(current_row),
                                 student_id: current_row[@student_id_column])
      index += 1
    end
  end

  private

  # This function returns a student's ACT Math score from a given row of the .xlsx file.
  # params: a row from the .xlsx file (processed_row).
  # return: a student's ACT Math Score as an integer.
  def self.retrieve_act_math(processed_row)
    processed_row[@act_math_column].to_i if processed_row[@act_math_column].present?
  end

  # This function returns a student's ACT Composite score from a given row
  # of the .xlsx file.
  # params: a row from the .xlsx file (processed_row).
  # return: a student's ACT Score as an integer.
  def self.retrieve_act(processed_row)
    processed_row[@act_column].to_i if processed_row[@act_column].present?
  end

  # This function returns a student's SAT Math score from a given row
  # of the .xlsx file.
  # params: a row from the .xlsx file (processed_row).
  # return: a student's SAT Math Score as an integer.
  def self.retrieve_sat_math(processed_row)
    processed_row[@sat_math_column].to_i if processed_row[@sat_math_column].present?
  end

  # This function returns a student's composite SAT score from a given row
  # of the .xlsx file.
  # params:a row from the .xlsx file (processed_row).
  # return: a student's SAT Score as an integer.
  def self.retrieve_sat(processed_row)
    (processed_row[@sat_math_column].to_i + processed_row[@sat_column].to_i) if processed_row[@sat_math_column].present? &&
                                                         processed_row[@sat_column].present?
  end

  # This function returns a student's name from a given row of the .xlsx file.
  # It constructs the full name based on the preferred name
  # and last name of students; if there is no preferred name,
  # it uses the regular first name.
  # params: a row of the .xlsx file (processed_row).
  # return: a student's name (as a string),
  # consisting of a first name or preferred name combined with a last name.
  def self.retrieve_name(processed_row)
    if processed_row[@preferred_name_column].present?
      processed_row[@preferred_name_column] + ' ' + processed_row[@last_name_column]
    else
      processed_row[@first_name_column] + ' ' + processed_row[@last_name_column]
    end
  end

  # This method composes a student's name from the Enrollments file.
  # It combines either the student's preferred name and last name
  # or their first name and last name, depending on whether the preferred name exists.
  # params: an array representing a row from the Enrollments file (processed_row).
  # return: a student's name as a string.
  def self.retrieve_name_from_enrollments(processed_row)
    if processed_row[@enrollments_preferred_name_column].present?
      processed_row[@enrollments_preferred_name_column] + ' ' + processed_row[@enrollments_last_name_column]
    else
      processed_row[@enrollments_first_name_column] + ' ' + processed_row[@enrollments_last_name_column]
    end
  end

  # This method creates a student based on the Enrollments file;
  # this is only used if a student is not already created when the Enrollments file is uploaded.
  # params: an array representing a row from the Enrollments file (processed_row).
  def self.create_from_enrollment(processed_row)
    Student.create!(nh_value: Fnv::Hash.fnv_1a(retrieve_name_from_enrollments(processed_row),
                                               size: 32),
                    research_consent?: false,
                    student_id: processed_row[@enrollments_student_id_column].to_i)
  end

  # This method serves as a shortcut with find_by to query the primary key.
  # While not directly needed for Students, it may be useful for unifying method calls
  # with other Models.
  # params: an integer Student ID (id).
  # return: an ActiveRecord object corresponding to the primary key given.
  def self.by_primary_key(id)
    find_by(student_id: id)
  end

  # This method acts like by_primary_key, but also attempts to validate
  # getting a student by their primary key with a comparison of nh_value via hashing a name.
  # params: an integer Student ID (id) and a string of a student's full name (name).
  # return: an ActiveRecord object corresponding to the primary key given
  # and the validation of said primary key.
  def self.by_valid_id(id, name)
    find_by(student_id: id.to_i, nh_value: Fnv::Hash.fnv_1a(name, size: 32))
  end
end