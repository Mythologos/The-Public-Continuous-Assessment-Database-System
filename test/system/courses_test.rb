require "application_system_test_case"

class CoursesTest < ApplicationSystemTestCase
  setup do
    @course = courses(:one)
  end

  test "visiting the index" do
    visit courses_url
    assert_selector "h1", text: "Courses"
  end

  test "creating a Course" do
    visit courses_url
    click_on "New Course"

    fill_in "Auxiliary course discipline", with: @course.auxiliary_course_discipline
    fill_in "Auxiliary course", with: @course.auxiliary_course_id
    fill_in "Course discipline", with: @course.course_discipline
    fill_in "Course", with: @course.course_id
    fill_in "Course title", with: @course.course_title
    fill_in "Prerequisite discipline 1", with: @course.prerequisite_discipline_1
    fill_in "Prerequisite discipline 2", with: @course.prerequisite_discipline_2
    fill_in "Prerequisite id 1", with: @course.prerequisite_id_1
    fill_in "Prerequisite id 2", with: @course.prerequisite_id_2
    click_on "Create Course"

    assert_text "Course was successfully created"
    click_on "Back"
  end

  test "updating a Course" do
    visit courses_url
    click_on "Edit", match: :first

    fill_in "Auxiliary course discipline", with: @course.auxiliary_course_discipline
    fill_in "Auxiliary course", with: @course.auxiliary_course_id
    fill_in "Course discipline", with: @course.course_discipline
    fill_in "Course", with: @course.course_id
    fill_in "Course title", with: @course.course_title
    fill_in "Prerequisite discipline 1", with: @course.prerequisite_discipline_1
    fill_in "Prerequisite discipline 2", with: @course.prerequisite_discipline_2
    fill_in "Prerequisite id 1", with: @course.prerequisite_id_1
    fill_in "Prerequisite id 2", with: @course.prerequisite_id_2
    click_on "Update Course"

    assert_text "Course was successfully updated"
    click_on "Back"
  end

  test "destroying a Course" do
    visit courses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Course was successfully destroyed"
  end
end
