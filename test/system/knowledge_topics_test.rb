require "application_system_test_case"

class KnowledgeTopicsTest < ApplicationSystemTestCase
  setup do
    @knowledge_topic = knowledge_topics(:one)
  end

  test "visiting the index" do
    visit knowledge_topics_url
    assert_selector "h1", text: "Knowledge Topics"
  end

  test "creating a Knowledge topic" do
    visit knowledge_topics_url
    click_on "New Knowledge Topic"

    fill_in "Active topic end?", with: @knowledge_topic.active_topic_end?
    fill_in "Active topic start?", with: @knowledge_topic.active_topic_start?
    fill_in "Kt area", with: @knowledge_topic.kt_area
    fill_in "Kt", with: @knowledge_topic.kt_id
    fill_in "Kt name", with: @knowledge_topic.kt_name
    fill_in "Kt unit", with: @knowledge_topic.kt_unit
    fill_in "Year added", with: @knowledge_topic.year_added
    click_on "Create Knowledge topic"

    assert_text "Knowledge topic was successfully created"
    click_on "Back"
  end

  test "updating a Knowledge topic" do
    visit knowledge_topics_url
    click_on "Edit", match: :first

    fill_in "Active topic end?", with: @knowledge_topic.active_topic_end?
    fill_in "Active topic start?", with: @knowledge_topic.active_topic_start?
    fill_in "Kt area", with: @knowledge_topic.kt_area
    fill_in "Kt", with: @knowledge_topic.kt_id
    fill_in "Kt name", with: @knowledge_topic.kt_name
    fill_in "Kt unit", with: @knowledge_topic.kt_unit
    fill_in "Year added", with: @knowledge_topic.year_added
    click_on "Update Knowledge topic"

    assert_text "Knowledge topic was successfully updated"
    click_on "Back"
  end

  test "destroying a Knowledge topic" do
    visit knowledge_topics_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Knowledge topic was successfully destroyed"
  end
end
