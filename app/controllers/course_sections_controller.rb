class CourseSectionsController < ApplicationController
  before_action :set_course_section, only: %i[show edit update destroy]

  # GET /course_sections
  # GET /course_sections.json
  def index
    @course_sections = CourseSection.all
  end

  # GET /course_sections/1
  # GET /course_sections/1.json
  def show
    render
  end

  # GET /course_sections/new
  def new
    @course_section = CourseSection.new
  end

  # GET /course_sections/1/edit
  def edit
    render
  end

  # POST /course_sections
  # POST /course_sections.json
  def create
    @course_section = CourseSection.new(course_section_params)

    respond_to do |format|
      if @course_section.save
        format.html { redirect_to @course_section, notice: 'A course section was successfully created.' }
        format.json { render :show, status: :created, location: @course_section }
      else
        format.html { render :new }
        format.json { render json: @course_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_sections/1
  # PATCH/PUT /course_sections/1.json
  def update
    respond_to do |format|
      if @course_section.update(course_section_params)
        format.html { redirect_to @course_section, notice: 'A course section was successfully updated.' }
        format.json { render :show, status: :ok, location: @course_section }
      else
        format.html { render :edit }
        format.json { render json: @course_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_sections/1
  # DELETE /course_sections/1.json
  def destroy
    @course_section.destroy
    respond_to do |format|
      format.html { redirect_to course_sections_url, notice: 'A course section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # This method is simply an empty method that renders its corresponding page.
  # It does nothing else. This page is the page on which the method
  # upload can be accessed. See that method for its purpose.
  # return: the upload view.
  def upload_page
    render
  end

  # This method receives an XLSX file from the upload view
  # and utilizes it to insert or update data in the Course Sections relation.
  # It also takes data in text fields of a pedagogy type (ped_type), a semester
  # (s_off), and a year (y_off).
  # params: a .xlsx file and three text fields, two of which are Strings of
  # the pedagogy type (ped_type) and semester offered (s_off),
  # and one of which is a year of the year offered (y_off).
  def upload
    CourseSection.upload(params[:xlsx_file], params[:s_off], params[:y_off])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course_section
    ids = params[:id].split(',')
    @course_section = CourseSection.find_by(crn: ids[0], section_number: ids[1], year_offered: ids[2])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def course_section_params
    params.require(:course_section).permit(:crn, :course_id, :course_discipline,
                                           :faculty_name, :pedagogy_type,
                                           :rrk_quiz_version, :section_number,
                                           :semester_offered, :year_offered)
  end
end
