require "application_system_test_case"

class RrkQuestionsTest < ApplicationSystemTestCase
  setup do
    @rrk_question = rrk_questions(:one)
  end

  test "visiting the index" do
    visit rrk_questions_url
    assert_selector "h1", text: "Rrk Questions"
  end

  test "creating a Rrk question" do
    visit rrk_questions_url
    click_on "New Rrk Question"

    fill_in "Active question end?", with: @rrk_question.active_question_end?
    fill_in "Active question start?", with: @rrk_question.active_question_start?
    fill_in "Correct answer", with: @rrk_question.correct_answer
    fill_in "Course discipline", with: @rrk_question.course_discipline
    fill_in "Course", with: @rrk_question.course_id
    fill_in "Incorrect answer 1", with: @rrk_question.incorrect_answer_1
    fill_in "Incorrect answer 2", with: @rrk_question.incorrect_answer_2
    fill_in "Incorrect answer 3", with: @rrk_question.incorrect_answer_3
    fill_in "Incorrect answer 4", with: @rrk_question.incorrect_answer_4
    fill_in "Kt", with: @rrk_question.kt_id
    fill_in "Question number", with: @rrk_question.question_number
    fill_in "Question text", with: @rrk_question.question_text
    fill_in "Rrk quiz version", with: @rrk_question.rrk_quiz_version
    fill_in "Taxonomic", with: @rrk_question.taxonomic_id
    click_on "Create Rrk question"

    assert_text "Rrk question was successfully created"
    click_on "Back"
  end

  test "updating a Rrk question" do
    visit rrk_questions_url
    click_on "Edit", match: :first

    fill_in "Active question end?", with: @rrk_question.active_question_end?
    fill_in "Active question start?", with: @rrk_question.active_question_start?
    fill_in "Correct answer", with: @rrk_question.correct_answer
    fill_in "Course discipline", with: @rrk_question.course_discipline
    fill_in "Course", with: @rrk_question.course_id
    fill_in "Incorrect answer 1", with: @rrk_question.incorrect_answer_1
    fill_in "Incorrect answer 2", with: @rrk_question.incorrect_answer_2
    fill_in "Incorrect answer 3", with: @rrk_question.incorrect_answer_3
    fill_in "Incorrect answer 4", with: @rrk_question.incorrect_answer_4
    fill_in "Kt", with: @rrk_question.kt_id
    fill_in "Question number", with: @rrk_question.question_number
    fill_in "Question text", with: @rrk_question.question_text
    fill_in "Rrk quiz version", with: @rrk_question.rrk_quiz_version
    fill_in "Taxonomic", with: @rrk_question.taxonomic_id
    click_on "Update Rrk question"

    assert_text "Rrk question was successfully updated"
    click_on "Back"
  end

  test "destroying a Rrk question" do
    visit rrk_questions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Rrk question was successfully destroyed"
  end
end
