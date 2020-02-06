require "application_system_test_case"

class KtSloMappingsTest < ApplicationSystemTestCase
  setup do
    @kt_slo_mapping = kt_slo_mappings(:one)
  end

  test "visiting the index" do
    visit kt_slo_mappings_url
    assert_selector "h1", text: "Kt Slo Mappings"
  end

  test "creating a Kt slo mapping" do
    visit kt_slo_mappings_url
    click_on "New Kt Slo Mapping"

    fill_in "Kt", with: @kt_slo_mapping.kt_id
    fill_in "Slo", with: @kt_slo_mapping.slo_id
    click_on "Create Kt slo mapping"

    assert_text "Kt slo mapping was successfully created"
    click_on "Back"
  end

  test "updating a Kt slo mapping" do
    visit kt_slo_mappings_url
    click_on "Edit", match: :first

    fill_in "Kt", with: @kt_slo_mapping.kt_id
    fill_in "Slo", with: @kt_slo_mapping.slo_id
    click_on "Update Kt slo mapping"

    assert_text "Kt slo mapping was successfully updated"
    click_on "Back"
  end

  test "destroying a Kt slo mapping" do
    visit kt_slo_mappings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Kt slo mapping was successfully destroyed"
  end
end
