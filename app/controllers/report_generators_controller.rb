class ReportGeneratorsController < ApplicationController
  require 'rinruby'
  require 'prawn'
  require 'prawn-svg'

  # This function forms the Standard Report document on demand.
  # It creates three main charts and adaptively creates others depending on circumstances.
  # All charts concern average question or quiz scores based on certain criteria.
  # The first chart, table, and significant-difference visuals are created for Courses.
  # The second chart, table, and significant-difference visuals are created for Knowledge Topics.
  # The third chart and table are created for Student Learning Outcomes.
  # return: a .pdf file containing charts as described above.
  def download_standard_report
    download_setup

    q_number = 1
    # Query One:
    q1_results = standard_query(query_one.transpose, q_number)
    table_one = [['Course', '# QZs Taken', 'Current Term Average',
                  '# Past Terms', 'Past Average', 'Standard Deviation',
                  'Stat. Diff.?']] + q1_results[1]

    # Query One (Significant Difference):
    q1_significance_visuals = standard_significance_query(q1_results[1], q_number)

    q_number += 1
    # Query Two:
    q2_results = standard_query(query_two.transpose, q_number)
    table_two = [['Area', '# Students Answered', 'Current Term Average',
                  '# Past Terms', 'Past Average', 'Standard Deviation',
                  'Stat. Diff.?']] + q2_results[1]

    # Query Two (Significant Difference):
    q2_significance_visuals = standard_significance_query(q2_results[1], q_number)

    q_number += 1
    # Query Three:
    q3_results = standard_query(query_three.transpose, q_number)
    table_three = [['SLO', '# Students Answered', 'Current Term Average',
                    '# Past Terms', 'Past Average', 'Standard Deviation',
                    'Stat. Diff.?']] + q3_results[1]

    # PDF Creation:
    filename = 'Standard Report (' + Time.current.year.to_s + '_' +
               Time.current.month.to_s + '_' + Time.current.day.to_s + ').pdf'
    Prawn::Document.generate(filename) do |pdf|
      pdf.text 'Standard Report'
      q1_to_pdf(pdf, q1_results, table_one, q1_significance_visuals)
      pdf.start_new_page
      q2_to_pdf(pdf, q2_results, table_two, q2_significance_visuals)
      pdf.start_new_page
      q3_to_pdf(pdf, q3_results, table_three)
      pdf.number_pages '<page>', at: [pdf.bounds.right - 150, 0],
                                 width: 150,
                                 align: :right,
                                 start_count_at: 1
    end
    redirect_to controller: :pages, action: :reports
    send_file filename, type: 'application/pdf'
  end

  # TODO: alter name throughout program to instructor-specific standard report.
  # This function forms a version of Standard Report document specific to an instructor;
  # that is, the relevant courses displayed are filtered by those course sections
  # which an instructor taught during this semester. Previous versions of those courses,
  # regardless of whether or not the instructor taught them, are also included.
  # It creates two main charts and adaptively creates others depending on circumstances.
  # All charts concern average question or quiz scores based on certain criteria.
  # The first chart, table, and significant-difference visuals are created for Courses.
  # The second chart, table, and significant-difference visuals are created for Knowledge Topics.
  # return: a .pdf file containing charts as described above.
  def download_instructor_report
    download_setup
    instructor = params[:instructor_name]
    if CourseSection.by_latest_semester
                    .joins(:rrk_quiz)
                    .where('course_sections.faculty_name': instructor,
                           'rrk_quizzes.active_quiz?': true).present?
      q_number = 1
      # Query One (with Instructor):
      q1_results = standard_query(query_one_i(instructor).transpose, q_number)
      table_one = [['Course', '# QZs Taken', 'Current Term Average',
                    '# Past Terms', 'Past Average', 'Standard Deviation',
                    'Stat. Diff.?']] + q1_results[1]

      # Query One (Significant Difference):
      q1_significance_visuals = instructor_significance_query(q1_results[1],
                                                              q_number,
                                                              instructor)

      q_number += 1
      # Query Two (with Instructor):
      q2_results = standard_query(query_two_i(instructor).transpose, q_number)
      table_two = [['Area', '# Students Answered', 'Current Term Average',
                    '# Past Terms', 'Past Average', 'Standard Deviation',
                    'Stat. Diff.?']] + q2_results[1]

      # Query Two (Significant Difference):
      q2_significance_visuals = instructor_significance_query(q2_results[1],
                                                              q_number,
                                                              instructor)

      # PDF Creation:
      filename = 'Instructor Report for ' + instructor + ' (' + Time.current.year.to_s +
                 '_' + Time.current.month.to_s + '_' + Time.current.day.to_s + ').pdf'
      Prawn::Document.generate(filename) do |pdf|
        pdf.text 'Instructor Report for ' + instructor
        q1_to_pdf(pdf, q1_results, table_one, q1_significance_visuals)
        pdf.start_new_page
        q2_to_pdf(pdf, q2_results, table_two, q2_significance_visuals)
        pdf.number_pages '<page>', options = { at: [pdf.bounds.right - 150, 0],
                                               width: 150,
                                               align: :right,
                                               start_count_at: 1 }
      end
      send_file filename, type: 'application/pdf'
    else
      redirect_to controller: :pages, action: :reports
      # TODO: figure out how to send an alert.
    end
  end

  private

  # This function sets up for creating a report by calling the relevant libraries for use
  # and assigning frequently-used variables to R with Rinruby.
  def download_setup
    # This data is necessary for quite a few queries,
    # so it is retrieved and assigned here.
    setup_libraries
    setup_functions
    R.assign 'current_year', CourseSection.latest_year
    R.assign 'current_semester', CourseSection.latest_semester
  end

  # This function sets up the libraries to be used in R code with Rinruby.
  def setup_libraries
    R.eval <<-LIBRARIES
      library(svglite)
      library(ggplot2)
      library(tidyr)
      library(magrittr)
      library(dplyr)
      library(purrr)
    LIBRARIES
  end

  # This function defines the functions to be used in R code with Rinruby.
  # It also defines the significance value.
  def setup_functions
    R.eval <<-FUNCTIONS
      significance = .05
      get_significance_by_group <- function(data, average) {
        if(average %>% is("double") & !is.nan(average)) {
          t.test(data, mu = average)$p.value < significance
        } else {
          FALSE
        }
      }
    FUNCTIONS
  end

  # This method gets the graphs and tables necessary for the Standard Report.
  # params: the columns derived from a query (columns)
  # and the number of the query to which the columns respond (query_number).
  # return: an array containing the relevant chart and table data.
  def standard_query(columns, query_number)
    case query_number
    when 1
      table_one = adjust_table(get_table_one(columns))
      [get_chart_one(columns), table_one]
    when 2
      table_two = adjust_table(get_table_two(columns))
      [get_chart_two(columns), table_two]
    when 3
      table_three = adjust_table(get_table_three(columns))
      [get_chart_three(columns), table_three]
    else
      puts 'Invalid query number.'
      # TODO: have better error-handling for this...
    end
  end

  # This method takes an array (called a table here)
  # and alters it according to its contents.
  # If the array contains arrays, the array's transpose is taken.
  # If the array does not contain arrays, the array is flattened and placed in another array.
  # In use of this method, the first item alone is used as proof of whether the array
  # consists of arrays or of non-array types.
  # param: an array of objects (table).
  # return: an array altered as described above.
  def adjust_table(table)
    if table.first.instance_of?(Array)
      table.transpose
    else
      [table.flatten]
    end
  end

  # This method gets the graphs and tables necessary for the Standard Report's
  # statistically-significant queries.
  # params: the data derived from a query in table form (table)
  # and the number of the query to which the columns respond (query_number).
  # return: an array containing the relevant chart and table data.
  def standard_significance_query(table, query_number)
    significant_visuals = []
    table.each do |row|
      case query_number
      when 1
        significant_visuals.append(visualize_q1(row[0], sign_query_one(row[0]).transpose)) if row[-1] == 'TRUE'
      when 2
        significant_visuals.append(visualize_q2(row[0], sign_query_two(row[0]).transpose)) if row[-1] == 'TRUE'
      end
    end
    significant_visuals
  end

  # This method gets the graphs and tables necessary for the
  # Instructor-Specific Standard Report's statistically-significant queries.
  # params: the data derived from a query in table form (table)
  # the number of the query to which the columns respond (query_number),
  # and the relevant instructor for the data as a string (instructor).
  # return: an array containing the relevant chart and table data.
  def instructor_significance_query(table, query_number, instructor)
    significant_visuals = []
    table.each do |row|
      case query_number
      when 1
        significant_visuals.append(visualize_q1(row[0], sign_query_one_i(row[0], instructor).transpose)) if row[-1] == 'TRUE'
      when 2
        significant_visuals.append(visualize_q2(row[0], sign_query_two_i(row[0], instructor).transpose)) if row[-1] == 'TRUE'
      else
        puts 'Invalid query number.'
        # TODO: better error handling...
      end
    end
    significant_visuals
  end

  # This function handles the first query for the Standard Report.
  # This query retrieves relevant data for Course-related queries.
  # It gets all Enrollment data where the Enrollment is
  # of a course held in the current semester.
  # It uses CourseSections to get semester information.
  # return: the Course IDs, Course Disciplines, RRK Quiz Scores, Semesters, and Years
  # pertinent to those courses held during the latest semester.
  def query_one
    # TODO: REFACTOR QUERY
    # This item gets all current Course Sections.
    current_sections = CourseSection.by_latest_semester
    # This query gets the current course sections and gets rid of any duplicates.
    nested_query = subdivide(current_sections.pluck(:course_discipline,
                                                    :course_id,
                                                    :rrk_quiz_version))
    # Main Query:
    Enrollment.joins(:course_section)
              .where('enrollments.rrk_quiz_version': nested_query[2],
                     'enrollments.year_offered': (Time.now.year - 20)..Time.now.year,
                     'enrollments.course_discipline': nested_query[0],
                     'enrollments.course_id': nested_query[1])
              .where.not('enrollments.rrk_quiz_score': nil)
              .pluck('enrollments.course_id',
                     'enrollments.course_discipline',
                     'enrollments.rrk_quiz_score',
                     'course_sections.semester_offered',
                     'enrollments.year_offered')
  end

  # This function handles getting data to accommodate for statistical significance.
  # For all current course sections, it retrieves the relevant RRK Question data
  # and answer correctness so as to calculate averages per question.
  # params: a course discipline and ID coupled in a string (course).
  # return: the relevant Question IDs, Question Texts, various Answer Texts,
  # and Answer Correctness as described above.
  def sign_query_one(course)
    # This takes apart the Course Discipline and Course ID.
    course_items = course.partition(/[a-zA-z]*/)
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    CourseSection.joins(answers: [:rrk_question])
                 .by_latest_semester
                 .where(course_discipline: course_items[1],
                        course_id: course_items[2].to_i)
                 .distinct(false)
                 .pluck('rrk_questions.question_id',
                        'rrk_questions.question_text',
                        'rrk_questions.correct_answer',
                        'rrk_questions.incorrect_answer_1',
                        'rrk_questions.incorrect_answer_2',
                        'rrk_questions.incorrect_answer_3',
                        'rrk_questions.incorrect_answer_4',
                        Arel.sql('answers."correct?"'))
  end

  # This function handles the first query for the Instructor-Specific Standard Report.
  # This query retrieves relevant data for Course-related queries.
  # It gets all Enrollment data where the Enrollment is
  # of a course held in the current semester
  # and a specified instructor taught the course.
  # params: the name of the relevant instructor as a string (instructor_name).
  # return: the CRNs, Course IDs, Course Disciplines, RRK Quiz Scores, and Years
  # pertinent to those courses held during the latest semester.
  def query_one_i(instructor_name)
    # TODO: REFACTOR QUERY
    # This item gets all current Course Sections with a given instructor.
    current_sections = CourseSection.by_latest_semester.by_instructor(instructor_name)
    # This query gets the current course sections and gets rid of any duplicates.
    nested_query = subdivide(current_sections.pluck(:course_discipline,
                                                    :course_id,
                                                    :rrk_quiz_version))
    # Main Query:
    Enrollment.joins(:course_section)
              .where('enrollments.rrk_quiz_version': nested_query[2],
                     'enrollments.year_offered': (Time.now.year - 20)..Time.now.year,
                     'enrollments.course_discipline': nested_query[0],
                     'enrollments.course_id': nested_query[1])
              .where.not('enrollments.rrk_quiz_score': nil)
              .pluck('enrollments.course_id',
                     'enrollments.course_discipline',
                     'enrollments.rrk_quiz_score',
                     'course_sections.semester_offered',
                     'enrollments.year_offered')
  end

  # This function handles getting data to accommodate for statistical significance.
  # For all current course sections with a specified instructor,
  # it retrieves the relevant RRK Question data
  # and answer correctness so as to calculate averages per question.
  # params: a course discipline and ID coupled in a string (course)
  # and the name of the relevant instructor as a string (instructor_name).
  # return: the relevant Question IDs, Question Texts, various Answer Texts,
  # and Answer Correctness as described above.
  def sign_query_one_i(course, instructor)
    # This takes apart the Course Discipline and Course ID.
    course_items = course.partition(/[a-zA-z]*/)
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    CourseSection.joins(answers: [:rrk_question])
                 .by_instructor(instructor)
                 .by_latest_semester
                 .where(course_discipline: course_items[1],
                        course_id: course_items[2].to_i)
                 .distinct(false)
                 .pluck('rrk_questions.question_id',
                        'rrk_questions.question_text',
                        'rrk_questions.correct_answer',
                        'rrk_questions.incorrect_answer_1',
                        'rrk_questions.incorrect_answer_2',
                        'rrk_questions.incorrect_answer_3',
                        'rrk_questions.incorrect_answer_4',
                        Arel.sql('answers."correct?"'))
  end

  # This function handles the second query for the Standard Report.
  # This query retrieves relevant data for Knowledge Topic-related queries.
  # It gets all Knowledge Topic data relevant to Course Sections
  # that have had quizzes in the past twenty years.
  # return: the KT Areas, KT IDs, KT Units, Question IDs, Answer-Correctness,
  # Student IDs, Semesters Offered, and Years Offered
  # fulfilling the conditions described above.
  def query_two
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    KnowledgeTopic.joins(question_topic_mappings:
                             [rrk_question:
                                  [answers:
                                       [:course_section]]])
                  .where('course_sections.year_offered':
                             (Time.now.year - 20)..Time.now.year)
                  .pluck('knowledge_topics.kt_area',
                         'knowledge_topics.kt_id',
                         'knowledge_topics.kt_unit',
                         'rrk_questions.question_id',
                         Arel.sql('answers."correct?"'),
                         'answers.student_id',
                         'course_sections.semester_offered',
                         'course_sections.year_offered')
  end

  # This function handles getting data to accommodate for statistical significance.
  # It gets all Knowledge Topic data from a specified Knowledge Area that is
  # relevant to Course Sections that have had quizzes in the past twenty years.
  # params: a string that represents a Knowledge Area (knowledge_area).
  # return: the KT Areas, KT IDs, KT Units, Question IDs, Answer-Correctness,
  # Student IDs, Semesters Offered, and Years Offered
  # fulfilling the conditions described above.
  def sign_query_two(knowledge_area)
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    KnowledgeTopic.joins(question_topic_mappings:
                             [rrk_question:
                                  [answers:
                                       [:course_section]]])
                  .where('knowledge_topics.kt_area': knowledge_area,
                         'course_sections.year_offered':
                             (Time.now.year - 20)..Time.now.year)
                  .pluck('knowledge_topics.kt_area',
                         'knowledge_topics.kt_id',
                         'knowledge_topics.kt_unit',
                         'rrk_questions.question_id',
                         Arel.sql('answers."correct?"'),
                         'answers.student_id',
                         'course_sections.semester_offered',
                         'course_sections.year_offered')
  end

  # This function handles the second query for the Standard Report.
  # This query retrieves relevant data for Knowledge Topic-related queries.
  # It gets all Knowledge Topic data relevant to Course Sections
  # that have had quizzes in the past twenty years.
  # It is also filtered by a specific instructor.
  # params: the name of the relevant instructor as a string (instructor_name).
  # return: the KT Areas, KT IDs, KT Units, Question IDs, Answer-Correctness,
  # Student IDs, Semesters Offered, and Years Offered
  # fulfilling the conditions described above.
  def query_two_i(instructor_name)
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    KnowledgeTopic.joins(question_topic_mappings:
                             [rrk_question:
                                  [answers:
                                       [:course_section]]])
                  .where('course_sections.year_offered':
                             (Time.now.year - 20)..Time.now.year,
                         'course_sections.faculty_name':
                             instructor_name)
                  .pluck('knowledge_topics.kt_area',
                         'knowledge_topics.kt_id',
                         'knowledge_topics.kt_unit',
                         'rrk_questions.question_id',
                         Arel.sql('answers."correct?"'),
                         'answers.student_id',
                         'course_sections.semester_offered',
                         'course_sections.year_offered')
  end

  # This function handles getting data to accommodate for statistical significance.
  # It gets all Knowledge Topic data from a specified Knowledge Area that is
  # relevant to Course Sections that have had quizzes in the past twenty years
  # and are taught by a specified instructor.
  # params: a string that represents a Knowledge Area (knowledge_area)
  # and a string that represents an instructor's name (instructor).
  # return: the KT Areas, KT IDs, KT Units, Question IDs, Answer-Correctness,
  # Student IDs, Semesters Offered, and Years Offered
  # fulfilling the conditions described above.
  def sign_query_two_i(knowledge_area, instructor)
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    KnowledgeTopic.joins(question_topic_mappings:
                             [rrk_question:
                                  [answers:
                                       [:course_section]]])
                  .where('knowledge_topics.kt_area':
                             knowledge_area,
                         'course_sections.year_offered':
                   (Time.now.year - 20)..Time.now.year,
                         'course_sections.faculty_name':
                            instructor)
                  .pluck('knowledge_topics.kt_area',
                         'knowledge_topics.kt_id',
                         'knowledge_topics.kt_unit',
                         'rrk_questions.question_id',
                         Arel.sql('answers."correct?"'),
                         'answers.student_id',
                         'course_sections.semester_offered',
                         'course_sections.year_offered')
  end

  # This function handles the third query for the Standard Report.
  # This query retrieves relevant data for Student Learning Outcome-related queries.
  # It gets all Student Learning Objective data relevant to Course Sections
  # that have had quizzes in the past twenty years.
  # return: the SLO IDs, KT IDs, Question IDs, Answer-Correctness,
  # Student IDs, Semesters Offered, and Years Offered
  # fulfilling the conditions described above.
  def query_three
    # (Note: 'answers.correct?' requires Arel.sql to be properly detected.)
    StudentLearningOutcome.joins(kt_slo_mappings:
                                     [knowledge_topic:
                                           [question_topic_mappings:
                                                 [rrk_question:
                                                       [answers:
                                                             [:course_section]]]]])
                          .where('course_sections.year_offered':
                                     (Time.now.year - 20)..Time.now.year)
                          .pluck('student_learning_outcomes.slo_id',
                                 'knowledge_topics.kt_id',
                                 'rrk_questions.question_id',
                                 Arel.sql('answers."correct?"'),
                                 'answers.student_id',
                                 'course_sections.crn',
                                 'course_sections.semester_offered',
                                 'course_sections.year_offered')
  end

  # The following code generates the course-based chart for the Standard Report.
  # It levies Rinruby and R's Tidyverse to do so.
  # params: the relevant data columns derived from the database (q1_columns).
  # return: an array containing the SVG string representing the course chart.
  def get_chart_one(q1_columns)
    r_fields = %w[ids disciplines scores semesters years]
    query_setup(r_fields, q1_columns)
    R.eval <<-Q1_CHART
      enroll_df <- data.frame(ids, disciplines, scores, semesters, years) %>%
      unite(col = "courses", disciplines, ids, sep = "", remove = TRUE)

      enroll_df2 <- enroll_df %>% group_by(courses) %>%
      summarize(current_scores = mean(scores[semesters == current_semester & years == current_year]))

      q1_svg <- svgstring(width = 1.5, height = 1, standalone = FALSE)
      ggplot(data = enroll_df, aes(x = courses, y = scores)) +
      geom_boxplot(mapping = aes(fill = courses), size = .2, outlier.size = .2, show.legend = FALSE) +
      geom_point(data = enroll_df2, aes(x = courses, y = current_scores), 
      size = .4, stroke = .3, shape = 23, fill = "white", color = "black") +
      labs(title = "Average Quiz Scores per Course") +
      theme_light() +
      theme(title = element_text(size = 3),
      axis.title.x = element_text(size = 2.5),
      axis.title.y = element_text(size = 2.5),
      axis.text.x = element_text(size = 2, hjust = .5, angle = 90),
      axis.text.y = element_text(size = 2))

      dev.off()
    Q1_CHART
    R.pull('c(q1_svg())')
  end

  # The following code generates the course-based table for the Standard Report.
  # It levies Rinruby and R's Tidyverse to do so.
  # params: the relevant data columns derived from the database (q1_columns).
  # return: an array containing all of the table's columns (as arrays) except
  # for the header.
  def get_table_one(q1_columns)
    r_fields = %w[ids disciplines scores semesters years]
    query_setup(r_fields, q1_columns)
    R.eval <<-Q1_TABLE
      enroll_df <- data.frame(ids, disciplines, scores, semesters, years) %>%
      unite(col = "courses", disciplines, ids, sep = "", remove = TRUE) %>%
      mutate(is_current = (semesters == current_semester & years == current_year)) %>%
      group_by(courses) %>%
      summarize(number_takers = n(),
      standard_deviation = sd(scores),
      current_average = mean(scores[is_current]),
      past_average = mean(scores[!is_current]),
      number_past_terms = n_distinct(semesters[!is_current], years[!is_current]),
      p_values = get_significance_by_group(data = scores[is_current], average = past_average))
    Q1_TABLE
    [R.pull('enroll_df$courses'),
     R.pull('enroll_df$number_takers'),
     R.pull('enroll_df$current_average'),
     R.pull('enroll_df$number_past_terms'),
     R.pull('enroll_df$past_average'),
     R.pull('enroll_df$standard_deviation'),
     R.pull('map_chr(.x = enroll_df$p_values, .f = as.character)')]
  end

  # This function generates significant-difference visuals
  # for the course Standard Report analysis.
  # It filters data by course and visualizes data based upon question averages.
  # It also generates a table to correspond with these averages.
  # params: the relevant course to filter by as a string (course)
  # and the data columns, an array of arrays, ordered correspondingly
  # with r_fields (q2_sign_columns).
  # return: an array containing the an array with string SVG that represents
  # the chart described above and an array containing
  # the table also described above.
  def visualize_q1(course, q1_sign_columns)
    r_fields = %w[q_ids q_texts correct_answers incorrect_a1s incorrect_a2s
                  incorrect_a3s incorrect_a4s is_correct]
    query_setup(r_fields, q1_sign_columns)
    R.assign 'course', course
    R.eval <<-Q1_SIGNIFICANT
      question_df <- data.frame(q_ids, q_texts, correct_answers,
      incorrect_a1s, incorrect_a2s, incorrect_a3s, incorrect_a4s, is_correct) %>%
      group_by(q_ids, q_texts, correct_answers, incorrect_a1s, incorrect_a2s, incorrect_a3s, incorrect_a4s) %>%
      summarize(correct_answer_counts = sum(is_correct[is_correct == TRUE]),
      total_question_counts = n(), latest_scores = correct_answer_counts / total_question_counts)

      q1_sign_svg <- svgstring(width = 1.5, height = 1, standalone = FALSE)
      ggplot(data = question_df, aes(x = q_ids, y = latest_scores)) +
      geom_bar(aes(fill = q_ids), stat = "identity", size = .2, show.legend = FALSE) +
      labs(title = paste("Latest Scores per Question for ", course, sep = "")) +
      theme_light() +
      theme(title = element_text(size = 3),
      axis.title.x = element_text(size = 2.5),
      axis.title.y = element_text(size = 2.5),
      axis.text.x = element_text(size = 2, hjust = .5),
      axis.text.y = element_text(size = 2)) +
      ylim(0, 1) + scale_x_discrete(limits = q_ids)
      dev.off()
    Q1_SIGNIFICANT
    [R.pull('c(q1_sign_svg())'),
     [['QID', 'Question Text', 'Correct Answer', 'Incorrect Answer 1',
       'Incorrect Answer 2', 'Incorrect Answer 3', 'Incorrect Answer 4',
       'Latest Avg. Score']] + [R.pull('question_df$q_ids'),
                                R.pull('map_chr(.x = question_df$q_texts, .f = as.character)'),
                                R.pull('map_chr(.x = question_df$correct_answers, .f = as.character)'),
                                R.pull('map_chr(.x = question_df$incorrect_a1s, .f = as.character)'),
                                R.pull('map_chr(.x = question_df$incorrect_a2s, .f = as.character)'),
                                R.pull('map_chr(.x = question_df$incorrect_a3s, .f = as.character)'),
                                R.pull('map_chr(.x = question_df$incorrect_a4s, .f = as.character)'),
                                R.pull('question_df$latest_scores')].transpose]
  end

  # The following code generates the KT-based chart for the Standard Report.
  # It levies Rinruby and R's Tidyverse to do so.
  # params: the relevant data columns derived from the database (q2_columns).
  # return: an array containing the SVG string representing the KT chart.
  def get_chart_two(q2_columns)
    r_fields = %w[areas k_ids units q_ids is_correct s_ids semesters years]
    query_setup(r_fields, q2_columns)
    R.eval <<-Q2_CHART
      knowledge_df <- data.frame(areas, k_ids, units, q_ids,
      is_correct, s_ids, semesters, years) %>%
      mutate(is_current = (semesters == current_semester & years == current_year)) %>%
      group_by(areas, s_ids, is_current, add = TRUE) %>%
      unite(col = "kq_ids", k_ids, q_ids, sep = "_", remove = FALSE) %>%
      summarize(scores = sum(is_correct[is_correct == TRUE]) / n_distinct(kq_ids))

      q2_svg <- svgstring(width = 1.5, height = 1, standalone = FALSE)
      ggplot(data = knowledge_df, aes(x = areas, y = scores)) +
      geom_boxplot(aes(fill = factor(is_current)), size = .2, outlier.size = .2, show.legend = TRUE) +
      ylab("scores") + labs(title = "Average Correctness per Knowledge Area", fill = "Time") +
      theme_light() +
      theme(title = element_text(size = 3),
      axis.title.x = element_text(size = 2.5),
      axis.title.y = element_text(size = 2.5),
      axis.text.x = element_text(size = 2, angle = 0, hjust = .5),
      axis.text.y = element_text(size = 2),
      legend.position = "right", 
      legend.title = element_text(size = 2.25),
      legend.text = element_text(size = 2),
      legend.key.width = unit(.2, "line"), 
      legend.key.height = unit(.2, "line"),
      legend.margin = margin(t = .25, r = .25, b = .25, l = .25, unit = "pt"),
      plot.margin = margin(t = .5, r = .5, b = .5, l = .5, unit = "pt")) +
      ylim(0, 1) +
      guides(fill = guide_legend(override.aes = list(size = 0.1))) +
      scale_fill_hue(name = "Time", breaks = c("FALSE", "TRUE"), labels = c("Previous", "Current"))

      dev.off()
    Q2_CHART
    R.pull('c(q2_svg())')
  end

  # The following code generates the KT-based table for the Standard Report.
  # It levies Rinruby and R's Tidyverse to do so.
  # params: the relevant data columns derived from the database (q2_columns).
  # return: an array containing all of the table's columns (as arrays)
  # except for the header.
  def get_table_two(q2_columns)
    r_fields = %w[areas k_ids units q_ids is_correct s_ids semesters years]
    query_setup(r_fields, q2_columns)
    R.eval <<-Q2_TABLE
      knowledge_df <- data.frame(areas, k_ids, units, q_ids, is_correct, s_ids, semesters, years) %>%
      mutate(is_current = (semesters == current_semester & years == current_year)) %>%
      group_by(areas, s_ids, is_current, add = TRUE) %>%
      unite(col = "kq_ids", k_ids, q_ids, sep = "_", remove = FALSE) %>%
      mutate(scores = sum(is_correct[is_correct == TRUE]) / n_distinct(kq_ids)) %>%
      ungroup() %>% group_by(areas) %>%
      summarize(number_takers = n_distinct(s_ids),
      current_average = mean(scores[is_current == TRUE]),
      number_past_terms = n_distinct(semesters[is_current == FALSE], 
      years[is_current == FALSE]),
      past_average = mean(scores[is_current == FALSE]),
      standard_deviation = sd(scores, na.rm = TRUE),
      p_values = get_significance_by_group(data = scores[is_current == TRUE], average = past_average))
    Q2_TABLE
    [R.pull('map_chr(.x = knowledge_df$areas, .f = as.character)'),
     R.pull('knowledge_df$number_takers'),
     R.pull('knowledge_df$current_average'),
     R.pull('knowledge_df$number_past_terms'),
     R.pull('knowledge_df$past_average'),
     R.pull('knowledge_df$standard_deviation'),
     R.pull('map_chr(.x = knowledge_df$p_values, .f = as.character)')]
  end

  # This function generates significant-difference visuals
  # for the KT Standard Report analysis.
  # It filters data by Knowledge Area and visualizes data
  # based upon knowledge unit averages.
  # params: the relevant knowledge area
  # to filter by as a string (knowledge_area)
  # and the data columns, an array of arrays,
  # ordered correspondingly with r_fields (q2_sign_columns).
  # return: an array containing the string SVG that represents
  # the chart described above.
  def visualize_q2(knowledge_area, q2_sign_columns)
    r_fields = %w[areas k_ids units q_ids is_correct s_ids semesters years]
    query_setup(r_fields, q2_sign_columns)
    R.assign 'relevant_ka', knowledge_area
    R.eval <<-Q2_SIGNIFICANT
      knowledge_unit_df <- data.frame(areas, k_ids, units, q_ids,
      is_correct, s_ids, semesters, years) %>%
      filter(areas == relevant_ka, semesters == current_semester, years == current_year) %>%
      group_by(units) %>%
      unite(col = "kq_ids", k_ids, q_ids, sep = "_", remove = FALSE) %>%
      summarize(correct_answer_counts = sum(is_correct[is_correct == TRUE]),
      total_question_counts = n_distinct(kq_ids, s_ids),
      latest_scores = correct_answer_counts / total_question_counts)

      q2_sign_svg <- svgstring(width = 1.75, height = 1.6, standalone = FALSE)
      ggplot(data = knowledge_unit_df, aes(x = units, y = latest_scores)) +
      geom_bar(aes(fill = units, group = units), stat = "identity", size = 2, show.legend = FALSE) +
      labs(title = paste("Scores per Knowledge Unit in Area ", relevant_ka, sep = "")) +
      theme_light() +
      theme(title = element_text(size = 3.5),
      axis.title.x = element_text(size = 3),
      axis.title.y = element_text(size = 3),
      axis.text.x = element_text(size = 2.75, angle = 45, hjust = .5),
      axis.text.y = element_text(size = 2.75)) +
      ylim(0, 1)

      dev.off()
    Q2_SIGNIFICANT
    R.pull('c(q2_sign_svg())')
  end

  # The following code generates the SLO-based chart for the Standard Report.
  # It levies Rinruby and R's Tidyverse to do so.
  # params: the relevant data columns derived from the database (q3_columns).
  # return: an array containing the SVG string representing the SLO chart.
  def get_chart_three(q3_columns)
    r_fields = %w[slos k_ids q_ids is_correct s_ids crns semesters years]
    query_setup(r_fields, q3_columns)
    R.eval <<-Q3_CHART
      outcome_df <- data.frame(slos, k_ids, q_ids, is_correct, s_ids, crns, semesters, years) %>%
      mutate(is_current = (semesters == current_semester & years == current_year)) %>%
      unite(col = "skq_ids", slos, k_ids, q_ids, sep = "_", remove = FALSE) %>%
      group_by(slos, s_ids, is_current, add = TRUE) %>%
      summarize(scores = sum(is_correct[is_correct == TRUE]) / n_distinct(skq_ids))
  
      q3_svg <- svgstring(width = 1.5, height = 1, standalone = FALSE)
      ggplot(data = outcome_df, aes(x = slos, y = scores)) +
      geom_boxplot(aes(group = interaction(slos, is_current), fill = factor(is_current)), size = .2, outlier.size = .2, show.legend = TRUE) +
      ylab("scores") + labs(title = "Average Correctness per Student Learning Outcome", fill = "Time") +
      theme_light() +
      theme(title = element_text(size = 3),
      axis.title.x = element_text(size = 2.5),
      axis.title.y = element_text(size = 2.5),
      axis.text.x = element_text(size = 2, angle = 0, hjust = .5),
      axis.text.y = element_text(size = 2), 
      legend.position = "right", 
      legend.title = element_text(size = 2.25),
      legend.text = element_text(size = 2),
      legend.key.width = unit(.2, "line"), 
      legend.key.height = unit(.2, "line"),
      legend.margin = margin(t = .25, r = .25, b = .25, l = .25, unit = "pt"),
      plot.margin = margin(t = .5, r = .5, b = .5, l = .5, unit = "pt")) +
      ylim(0, 1) +
      guides(fill = guide_legend(override.aes = list(size = 0.1))) +
      scale_fill_hue(name = "Time", breaks = c("FALSE", "TRUE"), labels = c("Previous", "Current"))
      
      dev.off()
    Q3_CHART
    R.pull('c(q3_svg())')
  end

  # The following code generates the SLO-based table for the Standard Report.
  # It levies Rinruby and R's Tidyverse to do so.
  # params: the relevant data columns derived from the database (q3_columns).
  # return: an array containing all of the table's columns (as arrays) except for the header.
  def get_table_three(q3_columns)
    r_fields = %w[slos k_ids q_ids is_correct s_ids crns semesters years]
    query_setup(r_fields, q3_columns)
    R.eval <<-Q3_TABLE
      outcome_df <- data.frame(slos, k_ids, q_ids, is_correct, s_ids, crns, semesters, years) %>%
      mutate(is_current = (semesters == current_semester & years == current_year)) %>%
      group_by(slos, s_ids, is_current) %>%
      unite(col = "skq_ids", slos, k_ids, q_ids, sep = "_", remove = FALSE) %>%
      mutate(scores = sum(is_correct[is_correct == TRUE]) / n_distinct(skq_ids)) %>%
      ungroup() %>% group_by(slos) %>%
      summarize(number_takers = n_distinct(s_ids),
      current_average = mean(scores[is_current == TRUE]),
      number_past_terms = n_distinct(semesters[is_current == FALSE],
      years[is_current == FALSE]),
      past_average = mean(scores[is_current == FALSE]),
      standard_deviation = sd(scores, na.rm = TRUE),
      p_values = get_significance_by_group(data = scores[is_current == TRUE], average = past_average))
    Q3_TABLE
    [R.pull('map_chr(.x = outcome_df$slos, .f = as.character)'),
     R.pull('outcome_df$number_takers'),
     R.pull('outcome_df$current_average'),
     R.pull('outcome_df$number_past_terms'),
     R.pull('outcome_df$past_average'),
     R.pull('outcome_df$standard_deviation'),
     R.pull('map_chr(.x = outcome_df$p_values, .f = as.character)')]
  end

  # This function uses Rinruby to assign arrays to names in R.
  # params: an array of Strings which represent the names of variables
  # that will be assigned to with Rinruby (r_fields)
  # and an array of arrays, each of which represents a column of data (query_columns).
  def query_setup(r_fields, query_columns)
    r_fields.each_with_index do |name, index|
      R.assign name, query_columns[index]
    end
  end

  # The following function is used to help manipulate data for queries.
  # It takes data divided into arrays that make up partial tuples
  # and subsequently loads this data into sets.
  # params: an array of arrays to cycle through (query).
  # return: an array of sets.
  def subdivide(query)
    set_list = []
    num_sets = query[0].size
    num_sets.times do
      set_list.push(Set[])
    end
    query.each do |query_tuple|
      query_tuple.each_with_index do |entry, index|
        set_list[index].add(entry)
      end
    end
    set_list
  end

  # This method adds data from the course-based Standard Report query
  # to a developing PDF file.
  # params: the pdf object from Prawn (pdf),
  # the SVG from the chart generator in an array (results),
  # the two-dimensional array that represents the relevant table (table),
  # and the SVGs generated based on significant difference (sign_visuals).
  def q1_to_pdf(pdf, results, table, sign_visuals)
    pdf.svg results[0], position: :center, vposition: 50
    pdf.move_down 10
    pdf.table(table,
              column_widths: [70, 45, 90, 50, 90, 90, 50],
              position: :center)
    sign_visuals.each do |visual|
      pdf.start_new_page
      pdf.move_down 10
      pdf.svg visual[0]
      pdf.start_new_page
      pdf.table(visual[1],
                column_widths: [30, 120, 65, 65, 65, 65, 65, 40],
                position: :center,
                cell_style: { size: 10 })
    end
  end

  # This method adds data from the course-based Standard Report query
  # to a developing PDF file.
  # params: the pdf object from Prawn (pdf),
  # the SVG from the chart generator in an array (results),
  # the two-dimensional array that represents the relevant table (table),
  # and the SVGs generated based on significant difference (sign_visuals).
  def q2_to_pdf(pdf, results, table, sign_visuals)
    pdf.svg results[0], position: :center, vposition: 50
    pdf.move_down 10
    pdf.table(table,
              column_widths: [40, 70, 95, 50, 95, 95, 95, 40],
              position: :center)
    sign_visuals.each do |visual|
      pdf.start_new_page
      pdf.move_down 10
      pdf.svg visual
    end
  end

  # This method adds data from the SLO-based Standard Report query
  # to a developing PDF file.
  # params: the pdf object from Prawn (pdf),
  # the SVG from the chart generator in an array (results),
  # and the two-dimensional array that represents the relevant table (table),
  def q3_to_pdf(pdf, results, table)
    pdf.svg results[0], position: :center, vposition: 50
    pdf.move_down 10
    pdf.table(table,
              column_widths: [40, 70, 95, 50, 95, 95, 95, 40],
              position: :center)
  end
end