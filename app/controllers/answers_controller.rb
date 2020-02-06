class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.all
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    render
  end

  # GET /answers/new
  def new
    @answer = Answer.new
  end

  # GET /answers/1/edit
  def edit
    render
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)

    respond_to do |format|
      if @answer.save
        format.html { redirect_to @answer, notice: 'An answer was successfully created.' }
        format.json { render :show, status: :created, location: @answer }
      else
        format.html { render :new }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to @answer, notice: 'An answer was successfully updated.' }
        format.json { render :show, status: :ok, location: @answer }
      else
        format.html { render :edit }
        format.json { render json: @answer.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to answers_url, notice: 'An answer was successfully destroyed.' }
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

  # This method receives a XLSX file from the upload view and
  # utilizes it to insert data in the Answers relation. It also
  # receives a course registration number (crn) and year (y_off)
  # from text fields.
  # params: a .xlsx file and two integers representing the CRN and Year_Offered,
  # respectively.
  def upload
    @invalid_id_list = Answer.upload(params[:xlsx_file], params[:y_off])
    if @invalid_id_list.empty?
      redirect_to controller: :pages, action: :home
    else
      render 'answers/id_mismatch_page'
    end
  end

  # This method is simply an empty method that renders its corresponding page.
  # It does nothing else. This page is the page on which any students
  # who inserted invalid IDs into the system can be viewed.
  # return: the id_mismatch view.
  def id_mismatch_page
    render
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    ids = params[:id].split(',')
    @answer = Answer.find_by(student_id: ids[0], question_id: ids[1])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def answer_params
    params.require(:answer).permit(:answer_given, :crn, :correct?, :question_id,
                                   :section_number, :student_id, :year_offered)
  end
end
