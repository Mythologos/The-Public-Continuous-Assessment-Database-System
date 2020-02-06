class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[show edit update destroy]

  # GET /enrollments
  # GET /enrollments.json
  def index
    @enrollments = Enrollment.all
  end

  # GET /enrollments/1
  # GET /enrollments/1.json
  def show
    render
  end

  # GET /enrollments/new
  def new
    @enrollment = Enrollment.new
  end

  # GET /enrollments/1/edit
  def edit
    render
  end

  # POST /enrollments
  # POST /enrollments.json
  def create
    @enrollment = Enrollment.new(enrollment_params)

    respond_to do |format|
      if @enrollment.save
        format.html { redirect_to @enrollment, notice: 'An enrollment was successfully created.' }
        format.json { render :show, status: :created, location: @enrollment }
      else
        format.html { render :new }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /enrollments/1
  # PATCH/PUT /enrollments/1.json
  def update
    respond_to do |format|
      if @enrollment.update(enrollment_params)
        format.html { redirect_to @enrollment, notice: 'An enrollment was successfully updated.' }
        format.json { render :show, status: :ok, location: @enrollment }
      else
        format.html { render :edit }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enrollments/1
  # DELETE /enrollments/1.json
  def destroy
    @enrollment.destroy
    respond_to do |format|
      format.html { redirect_to enrollments_url, notice: 'An enrollment was successfully destroyed.' }
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

  # This method receives a file from the upload view
  # and utilizes it to insert or update data in the Enrollments relation.
  # params: a .xlsx file (inside the params object).
  def upload
    file = params[:xlsx_student_file] || params[:xlsx_enrollment_file]
    Enrollment.upload(file)
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_enrollment
    ids = params[:id].split(',')
    @enrollment = Enrollment.find_by(crn: ids[0], section_number: ids[1],
                                     student_id: ids[2], year_offered: ids[3])
    puts @enrollment
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def enrollment_params
    params.require(:enrollment).permit(:crn, :course_id, :course_discipline,
                                       :relevant_major_participation,
                                       :rrk_quiz_score, :rrk_quiz_version,
                                       :section_number, :student_course_grade,
                                       :student_id, :year_offered)
  end
end