require 'test_helper'

class KtSloMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kt_slo_mapping = kt_slo_mappings(:one)
  end

  test "should get index" do
    get kt_slo_mappings_url
    assert_response :success
  end

  test "should get new" do
    get new_kt_slo_mapping_url
    assert_response :success
  end

  test "should create kt_slo_mapping" do
    assert_difference('KtSloMapping.count') do
      post kt_slo_mappings_url, params: { kt_slo_mapping: { kt_id: @kt_slo_mapping.kt_id, slo_id: @kt_slo_mapping.slo_id } }
    end

    assert_redirected_to kt_slo_mapping_url(KtSloMapping.last)
  end

  test "should show kt_slo_mapping" do
    get kt_slo_mapping_url(@kt_slo_mapping)
    assert_response :success
  end

  test "should get edit" do
    get edit_kt_slo_mapping_url(@kt_slo_mapping)
    assert_response :success
  end

  test "should update kt_slo_mapping" do
    patch kt_slo_mapping_url(@kt_slo_mapping), params: { kt_slo_mapping: { kt_id: @kt_slo_mapping.kt_id, slo_id: @kt_slo_mapping.slo_id } }
    assert_redirected_to kt_slo_mapping_url(@kt_slo_mapping)
  end

  test "should destroy kt_slo_mapping" do
    assert_difference('KtSloMapping.count', -1) do
      delete kt_slo_mapping_url(@kt_slo_mapping)
    end

    assert_redirected_to kt_slo_mappings_url
  end
end
