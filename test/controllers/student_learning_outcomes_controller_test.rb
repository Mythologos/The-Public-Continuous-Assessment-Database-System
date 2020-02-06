require 'test_helper'

class StudentLearningOutcomesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student_learning_outcome = student_learning_outcomes(:one)
  end

  test "should get index" do
    get student_learning_outcomes_url
    assert_response :success
  end

  test "should get new" do
    get new_student_learning_outcome_url
    assert_response :success
  end

  test "should create student_learning_outcome" do
    assert_difference('StudentLearningOutcome.count') do
      post student_learning_outcomes_url, params: { student_learning_outcome: { accreditation_body: @student_learning_outcome.accreditation_body, active_outcome_end?: @student_learning_outcome.active_outcome_end?, active_outcome_start?: @student_learning_outcome.active_outcome_start?, slo_description: @student_learning_outcome.slo_description, slo_id: @student_learning_outcome.slo_id, slo_name: @student_learning_outcome.slo_name, year_added: @student_learning_outcome.year_added } }
    end

    assert_redirected_to student_learning_outcome_url(StudentLearningOutcome.last)
  end

  test "should show student_learning_outcome" do
    get student_learning_outcome_url(@student_learning_outcome)
    assert_response :success
  end

  test "should get edit" do
    get edit_student_learning_outcome_url(@student_learning_outcome)
    assert_response :success
  end

  test "should update student_learning_outcome" do
    patch student_learning_outcome_url(@student_learning_outcome), params: { student_learning_outcome: { accreditation_body: @student_learning_outcome.accreditation_body, active_outcome_end?: @student_learning_outcome.active_outcome_end?, active_outcome_start?: @student_learning_outcome.active_outcome_start?, slo_description: @student_learning_outcome.slo_description, slo_id: @student_learning_outcome.slo_id, slo_name: @student_learning_outcome.slo_name, year_added: @student_learning_outcome.year_added } }
    assert_redirected_to student_learning_outcome_url(@student_learning_outcome)
  end

  test "should destroy student_learning_outcome" do
    assert_difference('StudentLearningOutcome.count', -1) do
      delete student_learning_outcome_url(@student_learning_outcome)
    end

    assert_redirected_to student_learning_outcomes_url
  end
end
