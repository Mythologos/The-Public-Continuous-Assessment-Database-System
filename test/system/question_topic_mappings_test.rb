require "application_system_test_case"

class QuestionTopicMappingsTest < ApplicationSystemTestCase
  setup do
    @question_topic_mapping = question_topic_mappings(:one)
  end

  test "visiting the index" do
    visit question_topic_mappings_url
    assert_selector "h1", text: "Question Topic Mappings"
  end

  test "creating a Question topic mapping" do
    visit question_topic_mappings_url
    click_on "New Question Topic Mapping"

    fill_in "Kt", with: @question_topic_mapping.kt_id
    fill_in "Question", with: @question_topic_mapping.question_id
    click_on "Create Question topic mapping"

    assert_text "Question topic mapping was successfully created"
    click_on "Back"
  end

  test "updating a Question topic mapping" do
    visit question_topic_mappings_url
    click_on "Edit", match: :first

    fill_in "Kt", with: @question_topic_mapping.kt_id
    fill_in "Question", with: @question_topic_mapping.question_id
    click_on "Update Question topic mapping"

    assert_text "Question topic mapping was successfully updated"
    click_on "Back"
  end

  test "destroying a Question topic mapping" do
    visit question_topic_mappings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Question topic mapping was successfully destroyed"
  end
end
