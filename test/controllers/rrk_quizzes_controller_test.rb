require 'test_helper'

class RrkQuizzesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rrk_quiz = rrk_quizzes(:one)
  end

  test "should get index" do
    get rrk_quizzes_url
    assert_response :success
  end

  test "should get new" do
    get new_rrk_quiz_url
    assert_response :success
  end

  test "should create rrk_quiz" do
    assert_difference('RrkQuiz.count') do
      post rrk_quizzes_url, params: { rrk_quiz: { active_quiz_end?: @rrk_quiz.active_quiz_end?, active_quiz_start?: @rrk_quiz.active_quiz_start?, course_discipline: @rrk_quiz.course_discipline, course_id: @rrk_quiz.course_id, quiz_creator: @rrk_quiz.quiz_creator, rrk_quiz_version: @rrk_quiz.rrk_quiz_version, total_number_of_questions: @rrk_quiz.total_number_of_questions } }
    end

    assert_redirected_to rrk_quiz_url(RrkQuiz.last)
  end

  test "should show rrk_quiz" do
    get rrk_quiz_url(@rrk_quiz)
    assert_response :success
  end

  test "should get edit" do
    get edit_rrk_quiz_url(@rrk_quiz)
    assert_response :success
  end

  test "should update rrk_quiz" do
    patch rrk_quiz_url(@rrk_quiz), params: { rrk_quiz: { active_quiz_end?: @rrk_quiz.active_quiz_end?, active_quiz_start?: @rrk_quiz.active_quiz_start?, course_discipline: @rrk_quiz.course_discipline, course_id: @rrk_quiz.course_id, quiz_creator: @rrk_quiz.quiz_creator, rrk_quiz_version: @rrk_quiz.rrk_quiz_version, total_number_of_questions: @rrk_quiz.total_number_of_questions } }
    assert_redirected_to rrk_quiz_url(@rrk_quiz)
  end

  test "should destroy rrk_quiz" do
    assert_difference('RrkQuiz.count', -1) do
      delete rrk_quiz_url(@rrk_quiz)
    end

    assert_redirected_to rrk_quizzes_url
  end
end
