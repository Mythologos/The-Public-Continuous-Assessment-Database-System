class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update destroy]

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    render
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
    render
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'A course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'A course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'A course was successfully destroyed.' }
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

  # This method receives an XLSX file from the upload view and
  # utilizes it to insert or update data in the Courses relation.
  # params: a .xlsx file.
  def upload
    Course.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    ids = params[:id].split(',')
    @course = Course.find_by(course_id: ids[0], course_discipline: ids[1])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def course_params
    params.require(:course).permit(:auxiliary_course_id, :auxiliary_course_discipline,
                                   :course_id, :course_discipline, :course_title,
                                   :prerequisite_id_1, :prerequisite_discipline_1,
                                   :prerequisite_id_2, :prerequisite_discipline_2)
  end
end