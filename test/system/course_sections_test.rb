require "application_system_test_case"

class CourseSectionsTest < ApplicationSystemTestCase
  setup do
    @course_section = course_sections(:one)
  end

  test "visiting the index" do
    visit course_sections_url
    assert_selector "h1", text: "Course Sections"
  end

  test "creating a Course section" do
    visit course_sections_url
    click_on "New Course Section"

    fill_in "Course discipline", with: @course_section.course_discipline
    fill_in "Course", with: @course_section.course_id
    fill_in "Crn", with: @course_section.crn
    fill_in "Faculty name", with: @course_section.faculty_name
    fill_in "Pedagogy type", with: @course_section.pedagogy_type
    fill_in "Rrk quiz version", with: @course_section.rrk_quiz_version
    fill_in "Semester offered", with: @course_section.semester_offered
    fill_in "Year offered", with: @course_section.year_offered
    click_on "Create Course section"

    assert_text "Course section was successfully created"
    click_on "Back"
  end

  test "updating a Course section" do
    visit course_sections_url
    click_on "Edit", match: :first

    fill_in "Course discipline", with: @course_section.course_discipline
    fill_in "Course", with: @course_section.course_id
    fill_in "Crn", with: @course_section.crn
    fill_in "Faculty name", with: @course_section.faculty_name
    fill_in "Pedagogy type", with: @course_section.pedagogy_type
    fill_in "Rrk quiz version", with: @course_section.rrk_quiz_version
    fill_in "Semester offered", with: @course_section.semester_offered
    fill_in "Year offered", with: @course_section.year_offered
    click_on "Update Course section"

    assert_text "Course section was successfully updated"
    click_on "Back"
  end

  test "destroying a Course section" do
    visit course_sections_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Course section was successfully destroyed"
  end
end
