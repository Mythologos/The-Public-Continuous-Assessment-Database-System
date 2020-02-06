require 'test_helper'

class KnowledgeTopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @knowledge_topic = knowledge_topics(:one)
  end

  test "should get index" do
    get knowledge_topics_url
    assert_response :success
  end

  test "should get new" do
    get new_knowledge_topic_url
    assert_response :success
  end

  test "should create knowledge_topic" do
    assert_difference('KnowledgeTopic.count') do
      post knowledge_topics_url, params: { knowledge_topic: { active_topic_end?: @knowledge_topic.active_topic_end?, active_topic_start?: @knowledge_topic.active_topic_start?, kt_area: @knowledge_topic.kt_area, kt_id: @knowledge_topic.kt_id, kt_name: @knowledge_topic.kt_name, kt_unit: @knowledge_topic.kt_unit, year_added: @knowledge_topic.year_added } }
    end

    assert_redirected_to knowledge_topic_url(KnowledgeTopic.last)
  end

  test "should show knowledge_topic" do
    get knowledge_topic_url(@knowledge_topic)
    assert_response :success
  end

  test "should get edit" do
    get edit_knowledge_topic_url(@knowledge_topic)
    assert_response :success
  end

  test "should update knowledge_topic" do
    patch knowledge_topic_url(@knowledge_topic), params: { knowledge_topic: { active_topic_end?: @knowledge_topic.active_topic_end?, active_topic_start?: @knowledge_topic.active_topic_start?, kt_area: @knowledge_topic.kt_area, kt_id: @knowledge_topic.kt_id, kt_name: @knowledge_topic.kt_name, kt_unit: @knowledge_topic.kt_unit, year_added: @knowledge_topic.year_added } }
    assert_redirected_to knowledge_topic_url(@knowledge_topic)
  end

  test "should destroy knowledge_topic" do
    assert_difference('KnowledgeTopic.count', -1) do
      delete knowledge_topic_url(@knowledge_topic)
    end

    assert_redirected_to knowledge_topics_url
  end
end
