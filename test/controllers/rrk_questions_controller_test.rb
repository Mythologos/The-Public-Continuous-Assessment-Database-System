require 'test_helper'

class RrkQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rrk_question = rrk_questions(:one)
  end

  test "should get index" do
    get rrk_questions_url
    assert_response :success
  end

  test "should get new" do
    get new_rrk_question_url
    assert_response :success
  end

  test "should create rrk_question" do
    assert_difference('RrkQuestion.count') do
      post rrk_questions_url, params: { rrk_question: { active_question_end?: @rrk_question.active_question_end?, active_question_start?: @rrk_question.active_question_start?, correct_answer: @rrk_question.correct_answer, course_discipline: @rrk_question.course_discipline, course_id: @rrk_question.course_id, incorrect_answer_1: @rrk_question.incorrect_answer_1, incorrect_answer_2: @rrk_question.incorrect_answer_2, incorrect_answer_3: @rrk_question.incorrect_answer_3, incorrect_answer_4: @rrk_question.incorrect_answer_4, kt_id: @rrk_question.kt_id, question_number: @rrk_question.question_number, question_text: @rrk_question.question_text, rrk_quiz_version: @rrk_question.rrk_quiz_version, taxonomic_id: @rrk_question.taxonomic_id } }
    end

    assert_redirected_to rrk_question_url(RrkQuestion.last)
  end

  test "should show rrk_question" do
    get rrk_question_url(@rrk_question)
    assert_response :success
  end

  test "should get edit" do
    get edit_rrk_question_url(@rrk_question)
    assert_response :success
  end

  test "should update rrk_question" do
    patch rrk_question_url(@rrk_question), params: { rrk_question: { active_question_end?: @rrk_question.active_question_end?, active_question_start?: @rrk_question.active_question_start?, correct_answer: @rrk_question.correct_answer, course_discipline: @rrk_question.course_discipline, course_id: @rrk_question.course_id, incorrect_answer_1: @rrk_question.incorrect_answer_1, incorrect_answer_2: @rrk_question.incorrect_answer_2, incorrect_answer_3: @rrk_question.incorrect_answer_3, incorrect_answer_4: @rrk_question.incorrect_answer_4, kt_id: @rrk_question.kt_id, question_number: @rrk_question.question_number, question_text: @rrk_question.question_text, rrk_quiz_version: @rrk_question.rrk_quiz_version, taxonomic_id: @rrk_question.taxonomic_id } }
    assert_redirected_to rrk_question_url(@rrk_question)
  end

  test "should destroy rrk_question" do
    assert_difference('RrkQuestion.count', -1) do
      delete rrk_question_url(@rrk_question)
    end

    assert_redirected_to rrk_questions_url
  end
end
