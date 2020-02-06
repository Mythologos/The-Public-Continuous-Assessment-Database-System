class RrkQuestionsController < ApplicationController
  before_action :set_rrk_question, only: %i[show edit update destroy]

  # GET /rrk_questions
  # GET /rrk_questions.json
  def index
    @rrk_questions = RrkQuestion.all
  end

  # GET /rrk_questions/1
  # GET /rrk_questions/1.json
  def show
    render
  end

  # GET /rrk_questions/new
  def new
    @rrk_question = RrkQuestion.new
  end

  # GET /rrk_questions/1/edit
  def edit
    render
  end

  # POST /rrk_questions
  # POST /rrk_questions.json
  def create
    @rrk_question = RrkQuestion.new(rrk_question_params)

    respond_to do |format|
      if @rrk_question.save
        format.html { redirect_to @rrk_question, notice: 'An RRK Question was successfully created.' }
        format.json { render :show, status: :created, location: @rrk_question }
      else
        format.html { render :new }
        format.json { render json: @rrk_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rrk_questions/1
  # PATCH/PUT /rrk_questions/1.json
  def update
    respond_to do |format|
      if @rrk_question.update(rrk_question_params)
        format.html { redirect_to @rrk_question, notice: 'An RRK Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @rrk_question }
      else
        format.html { render :edit }
        format.json { render json: @rrk_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rrk_questions/1
  # DELETE /rrk_questions/1.json
  def destroy
    @rrk_question.destroy
    respond_to do |format|
      format.html { redirect_to rrk_questions_url, notice: 'An RRK Question was successfully destroyed.' }
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
  # and utilizes it to insert or update data in the RRK Questions relation.
  # params: a .xlsx file.
  def upload
    RrkQuestion.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_rrk_question
    @rrk_question = RrkQuestion.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def rrk_question_params
    params.require(:rrk_question).permit(:active_question?, :correct_answer,
                                         :course_id, :course_discipline,
                                         :incorrect_answer_1, :incorrect_answer_2,
                                         :incorrect_answer_3, :incorrect_answer_4,
                                         :incorrect_answer_5, :rrk_quiz_version,
                                         :question_id, :question_text, :taxonomic_id)
  end
end