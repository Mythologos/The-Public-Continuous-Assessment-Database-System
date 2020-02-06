json.extract! course, :id, :auxiliary_course_id, :auxiliary_course_discipline, :course_id, :course_discipline, :course_title, :prerequisite_id_1, :prerequisite_discipline_1, :prerequisite_id_2, :prerequisite_discipline_2, :created_at, :updated_at
json.url course_url(course, format: :json)
