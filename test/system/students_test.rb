require "application_system_test_case"

class StudentsTest < ApplicationSystemTestCase
  setup do
    @student = students(:one)
  end

  test "visiting the index" do
    visit students_url
    assert_selector "h1", text: "Students"
  end

  test "creating a Student" do
    visit students_url
    click_on "New Student"

    fill_in "Act math score", with: @student.act_math_score
    fill_in "Act score", with: @student.act_score
    fill_in "Ethnicity", with: @student.ethnicity
    fill_in "Full name", with: @student.full_name
    fill_in "Gender", with: @student.gender
    fill_in "Math placement level", with: @student.math_placement_level
    fill_in "Sat math score", with: @student.sat_math_score
    fill_in "Sat score", with: @student.sat_score
    fill_in "Student", with: @student.student_id
    click_on "Create Student"

    assert_text "Student was successfully created"
    click_on "Back"
  end

  test "updating a Student" do
    visit students_url
    click_on "Edit", match: :first

    fill_in "Act math score", with: @student.act_math_score
    fill_in "Act score", with: @student.act_score
    fill_in "Ethnicity", with: @student.ethnicity
    fill_in "Full name", with: @student.full_name
    fill_in "Gender", with: @student.gender
    fill_in "Math placement level", with: @student.math_placement_level
    fill_in "Sat math score", with: @student.sat_math_score
    fill_in "Sat score", with: @student.sat_score
    fill_in "Student", with: @student.student_id
    click_on "Update Student"

    assert_text "Student was successfully updated"
    click_on "Back"
  end

  test "destroying a Student" do
    visit students_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Student was successfully destroyed"
  end
end
