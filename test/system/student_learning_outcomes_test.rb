require "application_system_test_case"

class StudentLearningOutcomesTest < ApplicationSystemTestCase
  setup do
    @student_learning_outcome = student_learning_outcomes(:one)
  end

  test "visiting the index" do
    visit student_learning_outcomes_url
    assert_selector "h1", text: "Student Learning Outcomes"
  end

  test "creating a Student learning outcome" do
    visit student_learning_outcomes_url
    click_on "New Student Learning Outcome"

    fill_in "Accreditation body", with: @student_learning_outcome.accreditation_body
    fill_in "Active outcome end?", with: @student_learning_outcome.active_outcome_end?
    fill_in "Active outcome start?", with: @student_learning_outcome.active_outcome_start?
    fill_in "Slo description", with: @student_learning_outcome.slo_description
    fill_in "Slo", with: @student_learning_outcome.slo_id
    fill_in "Slo name", with: @student_learning_outcome.slo_name
    fill_in "Year added", with: @student_learning_outcome.year_added
    click_on "Create Student learning outcome"

    assert_text "Student learning outcome was successfully created"
    click_on "Back"
  end

  test "updating a Student learning outcome" do
    visit student_learning_outcomes_url
    click_on "Edit", match: :first

    fill_in "Accreditation body", with: @student_learning_outcome.accreditation_body
    fill_in "Active outcome end?", with: @student_learning_outcome.active_outcome_end?
    fill_in "Active outcome start?", with: @student_learning_outcome.active_outcome_start?
    fill_in "Slo description", with: @student_learning_outcome.slo_description
    fill_in "Slo", with: @student_learning_outcome.slo_id
    fill_in "Slo name", with: @student_learning_outcome.slo_name
    fill_in "Year added", with: @student_learning_outcome.year_added
    click_on "Update Student learning outcome"

    assert_text "Student learning outcome was successfully updated"
    click_on "Back"
  end

  test "destroying a Student learning outcome" do
    visit student_learning_outcomes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Student learning outcome was successfully destroyed"
  end
end
