require "application_system_test_case"

class EnrollmentsTest < ApplicationSystemTestCase
  setup do
    @enrollment = enrollments(:one)
  end

  test "visiting the index" do
    visit enrollments_url
    assert_selector "h1", text: "Enrollments"
  end

  test "creating a Enrollment" do
    visit enrollments_url
    click_on "New Enrollment"

    fill_in "Course discipline", with: @enrollment.course_discipline
    fill_in "Course", with: @enrollment.course_id
    fill_in "Crn", with: @enrollment.crn
    fill_in "Relevant major participation", with: @enrollment.relevant_major_participation
    fill_in "Rrk quiz score", with: @enrollment.rrk_quiz_score
    fill_in "Rrk quiz version", with: @enrollment.rrk_quiz_version
    fill_in "Student course grade", with: @enrollment.student_course_grade
    fill_in "Student", with: @enrollment.student_id
    fill_in "Year offered", with: @enrollment.year_offered
    click_on "Create Enrollment"

    assert_text "Enrollment was successfully created"
    click_on "Back"
  end

  test "updating a Enrollment" do
    visit enrollments_url
    click_on "Edit", match: :first

    fill_in "Course discipline", with: @enrollment.course_discipline
    fill_in "Course", with: @enrollment.course_id
    fill_in "Crn", with: @enrollment.crn
    fill_in "Relevant major participation", with: @enrollment.relevant_major_participation
    fill_in "Rrk quiz score", with: @enrollment.rrk_quiz_score
    fill_in "Rrk quiz version", with: @enrollment.rrk_quiz_version
    fill_in "Student course grade", with: @enrollment.student_course_grade
    fill_in "Student", with: @enrollment.student_id
    fill_in "Year offered", with: @enrollment.year_offered
    click_on "Update Enrollment"

    assert_text "Enrollment was successfully updated"
    click_on "Back"
  end

  test "destroying a Enrollment" do
    visit enrollments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Enrollment was successfully destroyed"
  end
end
