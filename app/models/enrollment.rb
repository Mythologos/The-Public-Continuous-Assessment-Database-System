class Enrollment < ApplicationRecord
  self.primary_keys = :crn, :section_number, :student_id, :year_offered

  belongs_to :student, foreign_key: :student_id

  belongs_to :course_section, foreign_key: %i[crn section_number year_offered]

  # This is optional because we will record data on courses that
  # do not have RRK Quizzes attached to them.
  belongs_to :rrk_quiz, foreign_key: %i[course_id course_discipline rrk_quiz_version],
                        optional: true

  # TODO: move these?
  @enrollment_term_column = 0
  @enrollment_student_id_column = 2
  @enrollment_degree_type_column = 12
  @enrollment_degree_discipline_column = 13
  @enrollment_crn_column = 22
  @enrollment_course_discipline_column = 23
  @enrollment_course_id_column = 24
  @enrollment_section_number_column = 25
  @enrollment_course_grade_column = 30

  # The index begins at 6 because the data begins in the file's 7th row.
  @student_file_starting_row = 6
  @student_term_column = 0
  @student_crn_column = 1
  @student_course_discipline_column = 2
  @student_course_id_column = 3
  @student_section_column = 4
  @student_id_column = 5
  @student_first_degree_index = 17
  @student_first_degree_index_list = [18, 19, 20, 21]
  @student_second_degree_index = 22
  @student_second_degree_index_list = [23, 24, 25, 26]

  # This function handles routing the uploads appropriately.
  # params: a .xlsx file (file).
  def self.upload(file)
    if is_xlsx_student(file.headers)
      Enrollment.upload_xlsx_student(file)
    elsif is_xlsx_enrollment(file.headers)
      Enrollment.upload_xlsx_enrollment(file)
    end
  end

  # This method uses the Enrollments file to fill the Enrollments relation
  # with appropriate tuples.
  # params: a .xlsx file (xlsx_file).
  def self.upload_xlsx_enrollment(xlsx_file)
    # The file must be processed into a friendlier format before it can be used.
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    current_disciplines = Course.distinct.pluck(:course_discipline)
    processed_fileset.sheets.each do |sheet|
      # The following index starts at 1 to avoid the header line.
      index = 1
      while index < sheet.rows.size
        if current_disciplines.include?(sheet.rows[index][@enrollment_course_discipline_column])
          discipline = sheet.rows[index][@enrollment_course_discipline_column]
          cid = sheet.rows[index][@enrollment_course_id_column].to_i
          Course.where(course_discipline: discipline).pluck(:course_id).each do |cnum|
            if cid == cnum
              enroll_count = Enrollment.count
              process_row(cid, discipline, sheet.rows[index])
              Enrollment.count > enroll_count ? break : process_update(sheet.rows[index], cid, discipline)
            end
          end
        end
        index += 1
      end
    end
  end

  # This method uses the Student Data file to fill the Enrollments relation with tuples--
  # not complete tuples, but tuples nonetheless.
  # params: a .xlsx file (xlsx_file).
  def self.upload_xlsx_student(xlsx_file)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)

    index = @student_file_starting_row
    while index < processed_fileset.sheets.first.rows.size
      processed_row = processed_fileset.sheets.first.rows[index]
      cid = processed_row[@student_course_id_column]
      discipline = processed_row[@student_course_discipline_column]
      year = get_year(processed_row[@student_term_column])
      section = processed_row[@student_section_column]
      Enrollment.find_or_create_by!(crn: get_crn(processed_row[@student_crn_column], year, cid,
                                                 discipline, section),
                                    course_id: cid,
                                    course_discipline: discipline,
                                    relevant_major_participation: get_degree_student(processed_row),
                                    rrk_quiz_version: RrkQuiz.get_latest_version(discipline, cid),
                                    section_number: section,
                                    student_id: processed_row[@student_id_column],
                                    year_offered: year)
      index += 1
    end
  end

  private

  # This method determines whether a file is the xlsx_student_file by probing its headers.
  # params: the headers of a file as a string (headers).
  # return: a Boolean of whether the headers denote the Students file
  # (i.e. rather than the Enrollments file).
  def self.is_xlsx_student(headers)
    headers.slice((headers.index('"') + 1)..
                      (headers.index('"', headers.index('"') + 1) - 1)) == 'xlsx_student_file'
  end

  # This method determines whether a file is the xlsx_enrollment_file by probing its headers.
  # params: the headers of a file as a string (headers).
  # return: a Boolean of whether the headers denote the Enrollments file
  # (i.e. rather than the Students file).
  def self.is_xlsx_enrollment(headers)
    headers.slice((headers.index('"') + 1)..
                      (headers.index('"', headers.index('"') + 1) - 1)) == 'xlsx_enrollment_file'
  end

  # This method is a helper method to the former one and
  # actually performs the creation of Enrollment tuples.
  # params: a course number (cid),
  # a course discipline string (course_discipline),
  # and a row of the XLSX file (processed_row).
  def self.process_row(cid, discipline, processed_row)
    rrk_version = RrkQuiz.get_latest_version(discipline, cid)
    section_number = processed_row[@enrollment_section_number_column]
    year_offered = get_year(processed_row[@enrollment_term_column])
    crn = get_crn(processed_row[@enrollment_crn_column], year_offered, cid, discipline, section_number)
    unless Enrollment.by_primary_key(crn, section_number, processed_row[@enrollment_student_id_column],
                                     year_offered).present?
      unless Student.by_primary_key(processed_row[@enrollment_student_id_column]).present?
        Student.create_from_enrollment(processed_row)
      end
      Enrollment.create!(attributes = { crn: crn,
                                        course_id: cid,
                                        course_discipline: discipline,
                                        relevant_major_participation: get_degree_enrollment(processed_row),
                                        rrk_quiz_version: rrk_version,
                                        section_number: section_number,
                                        student_course_grade: get_grade(processed_row[@enrollment_course_grade_column]),
                                        student_id: processed_row[@enrollment_student_id_column],
                                        year_offered: year_offered })
    end
  end

  # TODO: alter this function and the degree-related collection to be discipline-agnostic.
  # This method determines what relevant degree a student has to Computer Science, if any.
  # params: a row of the XLSX file (processed_row).
  # return: a string representing a student's relevant degree.
  def self.get_degree_enrollment(processed_row)
    relevant_disciplines = %w[CSCI CSCA]
    if relevant_disciplines.include?(processed_row[@enrollment_degree_discipline_column])
      processed_row[@enrollment_degree_type_column]
    else
      'None'
    end
  end

  # TODO: alter this function and the degree-related collection to be discipline-agnostic.
  # TODO: put list-getters into their own functions.
  # This method determines what relevant degree a student has, if any.
  # params: a row of the XLSX file (processed_row).
  # return: a string representing a student's relevant degree.
  def self.get_degree_student(processed_row)
    first_degree_list = []
    @student_first_degree_index_list.each do |index|
      first_degree_list.push(processed_row[index])
    end

    second_degree_list = []
    @student_second_degree_index_list.each do |index|
      second_degree_list.push(processed_row[index])
    end

    if first_degree_list.include?('Computer Science')
      processed_row[@student_first_degree_index]
    elsif second_degree_list.include?('Computer Science')
      processed_row[@student_second_degree_index]
    else
      'None'
    end
  end

  # This method may update various aspects about an Enrollment tuple.
  # It gets the initial relation object by querying processed_row.
  # Then, it calls helper methods to examine individual attributes to update.
  # It does so as a secondary uploader for Enrollments--one after the Student Data file.
  # params: a row from the XLSX file (processed_row),
  # a course ID as an integer (cid),
  # and a course discipline as a string (discipline).
  def self.process_update(processed_row, cid, discipline)
    section_number = processed_row[@enrollment_section_number_column]
    year_offered = get_year(processed_row[@enrollment_term_column])
    crn = get_crn(processed_row[@enrollment_crn_column], year_offered, cid, discipline, section_number)
    enrollment_to_update = Enrollment.by_primary_key(crn, section_number, processed_row[@enrollment_student_id_column],
                                                     year_offered)
    handle_student_course_grade(enrollment_to_update, processed_row)
  end

  # This method updates a student's grade for a course if no grade is given
  # and if a grade value is present in the grade book.
  # params: an Enrollment ActiveRecord object (enrollment_to_update)
  # and a row from the XLSX file (processed_row).
  def self.handle_student_course_grade(enrollment_to_update, processed_row)
    # TODO: would there be any more abbreviations to look out for?
    if enrollment_to_update.student_course_grade == 'NG' && processed_row[@enrollment_course_grade_column].present?
      enrollment_to_update.update(student_course_grade: processed_row[@enrollment_course_grade_column])
    end
  end

  # This method examines a grade_cell item.
  # It returns either the contents of a grade_cell, a string, or 'NG' as a default item.
  # params: a grade, represented as a string (grade_cell).
  # return: a string of either the grade_cell or 'NG' if grade_cell is not present.
  def self.get_grade(grade_cell)
    grade_cell.present? ? grade_cell : 'NG'
  end

  # This method retrieves the CRN related to a course section.
  # It either gets the CRN from the XLSX file if the CRN
  # with the given section and year is already present in the database
  # or finds the CRN related to the other section-identifying information.
  # params: an integer CRN (crn_cell), an integer year (year),
  # an integer course ID (cid), a string course discipline (discipline),
  # and an integer section number (section_number).
  # return: the integer CRN related to a section.
  def self.get_crn(crn_cell, year_offered, cid, discipline, section_number)
    if CourseSection.by_primary_key(crn_cell, section_number, year_offered).present?
      crn_cell
    else
      CourseSection.by_specific_section(discipline, cid, section_number, year_offered)
                   .first
                   .crn
    end
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