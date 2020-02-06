require 'test_helper'

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
  end

  test "should get index" do
    get courses_url
    assert_response :success
  end

  test "should get new" do
    get new_course_url
    assert_response :success
  end

  test "should create course" do
    assert_difference('Course.count') do
      post courses_url, params: { course: { auxiliary_course_discipline: @course.auxiliary_course_discipline, auxiliary_course_id: @course.auxiliary_course_id, course_discipline: @course.course_discipline, course_id: @course.course_id, course_title: @course.course_title, prerequisite_discipline_1: @course.prerequisite_discipline_1, prerequisite_discipline_2: @course.prerequisite_discipline_2, prerequisite_id_1: @course.prerequisite_id_1, prerequisite_id_2: @course.prerequisite_id_2 } }
    end

    assert_redirected_to course_url(Course.last)
  end

  test "should show course" do
    get course_url(@course)
    assert_response :success
  end

  test "should get edit" do
    get edit_course_url(@course)
    assert_response :success
  end

  test "should update course" do
    patch course_url(@course), params: { course: { auxiliary_course_discipline: @course.auxiliary_course_discipline, auxiliary_course_id: @course.auxiliary_course_id, course_discipline: @course.course_discipline, course_id: @course.course_id, course_title: @course.course_title, prerequisite_discipline_1: @course.prerequisite_discipline_1, prerequisite_discipline_2: @course.prerequisite_discipline_2, prerequisite_id_1: @course.prerequisite_id_1, prerequisite_id_2: @course.prerequisite_id_2 } }
    assert_redirected_to course_url(@course)
  end

  test "should destroy course" do
    assert_difference('Course.count', -1) do
      delete course_url(@course)
    end

    assert_redirected_to courses_url
  end
end
