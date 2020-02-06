require 'test_helper'

class QuestionTopicMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question_topic_mapping = question_topic_mappings(:one)
  end

  test "should get index" do
    get question_topic_mappings_url
    assert_response :success
  end

  test "should get new" do
    get new_question_topic_mapping_url
    assert_response :success
  end

  test "should create question_topic_mapping" do
    assert_difference('QuestionTopicMapping.count') do
      post question_topic_mappings_url, params: { question_topic_mapping: { kt_id: @question_topic_mapping.kt_id, question_id: @question_topic_mapping.question_id } }
    end

    assert_redirected_to question_topic_mapping_url(QuestionTopicMapping.last)
  end

  test "should show question_topic_mapping" do
    get question_topic_mapping_url(@question_topic_mapping)
    assert_response :success
  end

  test "should get edit" do
    get edit_question_topic_mapping_url(@question_topic_mapping)
    assert_response :success
  end

  test "should update question_topic_mapping" do
    patch question_topic_mapping_url(@question_topic_mapping), params: { question_topic_mapping: { kt_id: @question_topic_mapping.kt_id, question_id: @question_topic_mapping.question_id } }
    assert_redirected_to question_topic_mapping_url(@question_topic_mapping)
  end

  test "should destroy question_topic_mapping" do
    assert_difference('QuestionTopicMapping.count', -1) do
      delete question_topic_mapping_url(@question_topic_mapping)
    end

    assert_redirected_to question_topic_mappings_url
  end
end
