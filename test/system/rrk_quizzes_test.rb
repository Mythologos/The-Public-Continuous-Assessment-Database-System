require "application_system_test_case"

class RrkQuizzesTest < ApplicationSystemTestCase
  setup do
    @rrk_quiz = rrk_quizzes(:one)
  end

  test "visiting the index" do
    visit rrk_quizzes_url
    assert_selector "h1", text: "Rrk Quizzes"
  end

  test "creating a Rrk quiz" do
    visit rrk_quizzes_url
    click_on "New Rrk Quiz"

    fill_in "Active quiz end?", with: @rrk_quiz.active_quiz_end?
    fill_in "Active quiz start?", with: @rrk_quiz.active_quiz_start?
    fill_in "Course discipline", with: @rrk_quiz.course_discipline
    fill_in "Course", with: @rrk_quiz.course_id
    fill_in "Quiz creator", with: @rrk_quiz.quiz_creator
    fill_in "Rrk quiz version", with: @rrk_quiz.rrk_quiz_version
    fill_in "Total number of questions", with: @rrk_quiz.total_number_of_questions
    click_on "Create Rrk quiz"

    assert_text "Rrk quiz was successfully created"
    click_on "Back"
  end

  test "updating a Rrk quiz" do
    visit rrk_quizzes_url
    click_on "Edit", match: :first

    fill_in "Active quiz end?", with: @rrk_quiz.active_quiz_end?
    fill_in "Active quiz start?", with: @rrk_quiz.active_quiz_start?
    fill_in "Course discipline", with: @rrk_quiz.course_discipline
    fill_in "Course", with: @rrk_quiz.course_id
    fill_in "Quiz creator", with: @rrk_quiz.quiz_creator
    fill_in "Rrk quiz version", with: @rrk_quiz.rrk_quiz_version
    fill_in "Total number of questions", with: @rrk_quiz.total_number_of_questions
    click_on "Update Rrk quiz"

    assert_text "Rrk quiz was successfully updated"
    click_on "Back"
  end

  test "destroying a Rrk quiz" do
    visit rrk_quizzes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Rrk quiz was successfully destroyed"
  end
end
