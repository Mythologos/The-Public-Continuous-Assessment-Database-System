json.extract! course_section, :crn, :course_id, :course_discipline, :faculty_name, :pedagogy_type, :rrk_quiz_version, :section_number, :semester_offered, :year_offered, :created_at, :updated_at
json.url course_section_url(course_section, format: :json)
