class CourseSection < ApplicationRecord
  self.primary_keys = :crn, :section_number, :year_offered
  belongs_to :course, foreign_key: %i[course_id course_discipline]

  belongs_to :rrk_quiz, foreign_key: %i[course_id course_discipline rrk_quiz_version],
                        optional: true

  has_many :enrollments, foreign_key: %i[crn section_number year_offered]
  has_many :students, through: :enrollments

  has_many :answers, foreign_key: %i[crn section_number year_offered]

  scope :by_section_group, ->(crn, year) { where(crn: crn, year_offered: year) }
  scope :by_specific_section, lambda { |discipline, cid, section_num, year|
    where(course_discipline: discipline, course_id: cid,
          section_number: section_num, year_offered: year)
  }

  # TODO: move these?
  @crn_column = 1
  @course_discipline_column = 2
  @course_id_column = 3
  @section_number_column = 4
  @faculty_name_column = 12
  @pedagogy_type_column = 13

  # TODO: have a handler for when there is a "blank" line below the data in the file.

  # This method uses the Course Sections file to fill the Course Sections relation
  # with appropriate tuples. It also uses two other pieces
  # of data from text fields--a semester (s_off) and a year (y_off) to do so.
  # params: a .xlsx file (xlsx_file), a string (s_off), and an integer (y_off).
  def self.upload(xlsx_file, s_off, y_off)
    processed_fileset = SimpleXlsxReader.open(xlsx_file.tempfile.path)
    # The actual data starts in the third line; thus, the index also does.
    index = 2
    while index < processed_fileset.sheets.first.rows.size
      current_row = processed_fileset.sheets.first.rows[index]
      course_disc = current_row[@course_discipline_column]
      course_id = current_row[@course_id_column]
      puts index
      CourseSection.find_or_create_by!(attributes = { crn: current_row[@crn_column],
                                                      course_id: course_id,
                                                      course_discipline: course_disc,
                                                      faculty_name:
                                                          get_faculty_name(current_row[@faculty_name_column]),
                                                      pedagogy_type:
                                                          evaluate_pedagogy_type(current_row[@pedagogy_type_column]),
                                                      rrk_quiz_version:
                                                          RrkQuiz.get_latest_version(course_disc, course_id),
                                                      section_number:
                                                          current_row[@section_number_column],
                                                      semester_offered:
                                                          convert_semester(s_off),
                                                      year_offered: y_off })
      index += 1
    end
  end

  private

  # This method processes a name_cell from the Course Sections File.
  # It removes unnecessary text from the name_cell file.
  # params: a name_cell item (a string).
  # return: a name_cell item with unnecessary text cut out;
  # alternatively, it returns nil if the name_cell is not present.
  def self.get_faculty_name(name_cell)
    if name_cell.present?
      if name_cell.include?('(P)')
        name_cell.gsub('(P)', '').strip
      else
        name_cell
      end
    end
  end

  # This method processes a pedagogy_type cell from the Course Sections file.
  # It returns ped_value or a default value.
  # params: a string representing a pedagogy type (ped_value).
  # return: a ped_value cell (a string) or a default value.
  def self.evaluate_pedagogy_type(ped_value)
    ped_value.present? ? ped_value : 'Active Learning'
  end

  # This method takes a string value that represents a semester
  # and converts it to an integer value to be stored in the database.
  # params: a string that represents a semester (semester_value).
  # return: an integer that corresponds with the given semester.
  def self.convert_semester(semester_value)
    case semester_value
    when 'Spring'
      1
    when 'Summer'
      5
    when 'Fall'
      9
    when 'Other'
      12
    else
      puts 'Invalid semester value.'
      # TODO: better error-handling.
    end
  end

  # This method serves as a shortcut with find_by to query the primary key.
  # params: an integer CRN (crn), an integer section number (section),
  # and an integer year (year).
  # return: an ActiveRecord object corresponding to the primary key given.
  def self.by_primary_key(crn, section, year)
    find_by(crn: crn, section_number: section, year_offered: year)
  end

  # This method retrieves the latest year for which a CourseSection is stored in the database.
  # return: an integer representing the latest year in which a CourseSection is offered.
  def self.latest_year
    CourseSection.maximum(:year_offered)
  end

  # This method gets all distinct ActiveRecord objects for CourseSection
  # which are offered in the highest year stored for CourseSection.
  # return: a Relation of ActiveRecord objects which satisfy the above measure.
  def self.by_latest_year
    where(year_offered: CourseSection.latest_year).distinct
  end

  # TODO: make a Semester enumeration to make code below more explicit.

  # This method retrieves the latest semester for which a CourseSection is stored in the database.
  # return: an integer representing the latest semester in which a CourseSection is offered.
  def self.latest_semester
    CourseSection.by_latest_year
                 .where(semester_offered: 1..9)
                 .maximum(:semester_offered)
  end

  # This method gets all distinct ActiveRecord objects for CourseSection
  # which are offered in the highest year and semester stored for CourseSection.
  # return: a Relation of ActiveRecord objects which satisfy the above measure.
  def self.by_latest_semester
    by_latest_year.where(semester_offered: CourseSection.latest_semester)
  end

  # This method gets all ActiveRecord objects for CourseSection
  # which a specified instructor teaches.
  # params: an instructor's name as a string (instructor_name).
  # return: a Relation of ActiveRecord objects which satisfy the above measure.
  def self.by_instructor(instructor_name)
    where(faculty_name: instructor_name)
  end
end