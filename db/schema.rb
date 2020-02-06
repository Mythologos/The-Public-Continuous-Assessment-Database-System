# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_13_184451) do
  # TODO: make hard-coded DB commands more flexible.
  # Composite-primary-keys gives Rails the logic; it doesn't touch the DB.

  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'answers', id: false, force: :cascade do |t|
    t.string 'answer_given', default: 'Unanswered'
    t.integer 'crn', null: false
    t.boolean 'correct?', null: false
    t.integer 'question_id', null: false
    t.integer 'section_number', limit: 2, null: false
    t.integer 'student_id', null: false
    t.integer 'year_offered', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.answers ADD PRIMARY KEY (question_id, student_id);')

  create_table 'course_sections', id: false, force: :cascade do |t|
    t.integer 'course_id', limit: 2, null: false
    t.string 'course_discipline', limit: 4, null: false
    t.integer 'crn', null: false
    t.string 'faculty_name'
    t.string 'pedagogy_type', default: 'Active Learning'
    t.integer 'rrk_quiz_version', limit: 2
    t.integer 'section_number', limit: 2, null: false
    t.integer 'semester_offered', limit: 2, null: false
    t.integer 'year_offered', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.course_sections ADD PRIMARY KEY (crn, section_number, year_offered);')

  create_table 'courses', id: false, force: :cascade do |t|
    t.integer 'auxiliary_course_id', limit: 2
    t.string 'auxiliary_course_discipline', limit: 4
    t.integer 'course_id', limit: 2, null: false
    t.string 'course_discipline', limit: 4, null: false
    t.string 'course_title', null: false
    t.integer 'prerequisite_id_1', limit: 2
    t.string 'prerequisite_discipline_1', limit: 4
    t.integer 'prerequisite_id_2', limit: 2
    t.string 'prerequisite_discipline_2', limit: 4
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.courses ADD PRIMARY KEY (course_id, course_discipline);')

  create_table 'enrollments', id: false, force: :cascade do |t|
    t.integer 'crn', null: false
    t.integer 'course_id', limit: 2, null: false
    t.string 'course_discipline', limit: 4, null: false
    t.string 'relevant_major_participation', default: 'None', null: false
    t.float 'rrk_quiz_score'
    t.integer 'rrk_quiz_version', limit: 2
    t.integer 'section_number', limit: 2, null: false
    t.string 'student_course_grade', limit: 2, default: 'NG', null: false
    t.integer 'student_id', null: false
    t.integer 'year_offered', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.enrollments ADD PRIMARY KEY (crn, section_number, student_id, year_offered);')

  create_table 'instructions', id: false, force: :cascade do |t|
    t.integer 'course_id', limit: 2, null: false
    t.string 'course_discipline', limit: 4, null: false
    t.integer 'kt_id', limit: 2, null: false
    t.string 'mapping_relationship', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.instructions ADD PRIMARY KEY (course_id, course_discipline, kt_id);')

  create_table 'knowledge_topics', id: false, force: :cascade do |t|
    t.boolean 'active_topic?', default: true, null: false
    t.string 'kt_area', limit: 4, null: false
    t.integer 'kt_id', limit: 2, null: false
    t.string 'kt_name', null: false
    t.string 'kt_unit', null: false
    t.integer 'year_added', limit: 2
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.knowledge_topics ADD PRIMARY KEY (kt_id);')

  create_table 'kt_slo_mappings', id: false, force: :cascade do |t|
    t.integer 'kt_id', limit: 2, null: false
    t.integer 'slo_id', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.kt_slo_mappings ADD PRIMARY KEY (kt_id, slo_id);')

  create_table 'question_topic_mappings', id: false, force: :cascade do |t|
    t.integer 'question_id', null: false
    t.integer 'kt_id', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.question_topic_mappings ADD PRIMARY KEY (kt_id, question_id);')

  create_table 'rrk_questions', primary_key: 'question_id', force: :cascade do |t|
    t.boolean 'active_question?', default: true, null: false
    t.string 'correct_answer', null: false
    t.integer 'course_id', limit: 2, null: false
    t.string 'course_discipline', limit: 4, null: false
    t.string 'incorrect_answer_1', null: false
    t.string 'incorrect_answer_2'
    t.string 'incorrect_answer_3'
    t.string 'incorrect_answer_4'
    t.string 'incorrect_answer_5', default: 'Unanswered'
    t.integer 'rrk_quiz_version', limit: 2, null: false
    t.string 'question_text', null: false
    t.integer 'taxonomic_id', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'rrk_quizzes', id: false, force: :cascade do |t|
    t.boolean 'active_quiz?', default: true, null: false
    t.integer 'course_id', limit: 2, null: false
    t.string 'course_discipline', limit: 4, null: false
    t.integer 'rrk_quiz_version', limit: 2, null: false
    t.string 'quiz_creator'
    t.integer 'total_number_of_questions', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.rrk_quizzes ADD PRIMARY KEY (course_id, course_discipline, rrk_quiz_version);')

  create_table 'student_learning_outcomes', id: false, force: :cascade do |t|
    t.string 'accreditation_body'
    t.boolean 'active_outcome?', default: true, null: false
    t.string 'slo_description', default: 'No description provided.'
    t.integer 'slo_id', limit: 2, null: false
    t.string 'slo_name', null: false
    t.integer 'year_added', limit: 2, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.student_learning_outcomes ADD PRIMARY KEY (slo_id);')

  create_table 'students', id: false, force: :cascade do |t|
    t.integer 'act_math_score', limit: 2
    t.integer 'act_score', limit: 2
    t.string 'ethnicity'
    t.string 'gender'
    t.string 'math_placement_level', limit: 3
    t.integer 'nh_value', limit: 6, null: false
    t.boolean 'research_consent?', default: false
    t.integer 'sat_math_score', limit: 2
    t.integer 'sat_score', limit: 2
    t.integer 'student_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.students ADD PRIMARY KEY (student_id);')

  create_table 'taxonomies', id: false, force: :cascade do |t|
    t.string 'taxonomic_description'
    t.integer 'taxonomic_id', limit: 2, null: false
    t.string 'taxonomic_name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  ActiveRecord::Base.connection.execute('ALTER TABLE public.taxonomies ADD PRIMARY KEY (taxonomic_id);')

  ActiveRecord::Base.connection.execute('ALTER TABLE public.answers ADD FOREIGN KEY (question_id) REFERENCES rrk_questions(question_id);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.answers ADD FOREIGN KEY (student_id) REFERENCES public.students(student_id);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.answers ADD FOREIGN KEY (crn, section_number, year_offered) REFERENCES public.course_sections(crn, section_number, year_offered);')

  ActiveRecord::Base.connection.execute('ALTER TABLE public.course_sections ADD FOREIGN KEY (course_id, course_discipline) REFERENCES public.courses(course_id, course_discipline);')
  # Because the second Course Sections FK is optional, it shouldn't be enforced.

  ActiveRecord::Base.connection.execute('ALTER TABLE public.enrollments ADD FOREIGN KEY (student_id) REFERENCES public.students(student_id);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.enrollments ADD FOREIGN KEY (crn, section_number, year_offered) REFERENCES public.course_sections(crn, section_number, year_offered);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.enrollments ADD FOREIGN KEY (course_id, course_discipline, rrk_quiz_version) REFERENCES public.rrk_quizzes(course_id, course_discipline, rrk_quiz_version);')

  ActiveRecord::Base.connection.execute('ALTER TABLE public.instructions ADD FOREIGN KEY (kt_id) REFERENCES public.knowledge_topics(kt_id);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.instructions ADD FOREIGN KEY (course_id, course_discipline) REFERENCES public.courses(course_id, course_discipline);')

  ActiveRecord::Base.connection.execute('ALTER TABLE public.kt_slo_mappings ADD FOREIGN KEY (kt_id) REFERENCES public.knowledge_topics(kt_id);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.kt_slo_mappings ADD FOREIGN KEY (slo_id) REFERENCES public.student_learning_outcomes(slo_id);')

  ActiveRecord::Base.connection.execute('ALTER TABLE public.question_topic_mappings ADD FOREIGN KEY (kt_id) REFERENCES public.knowledge_topics(kt_id);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.question_topic_mappings ADD FOREIGN KEY (question_id) REFERENCES public.rrk_questions(question_id);')

  ActiveRecord::Base.connection.execute('ALTER TABLE public.rrk_questions ADD FOREIGN KEY (course_id, course_discipline, rrk_quiz_version) REFERENCES public.rrk_quizzes(course_id, course_discipline, rrk_quiz_version);')
  ActiveRecord::Base.connection.execute('ALTER TABLE public.rrk_questions ADD FOREIGN KEY (taxonomic_id) REFERENCES public.taxonomies(taxonomic_id);')
end
