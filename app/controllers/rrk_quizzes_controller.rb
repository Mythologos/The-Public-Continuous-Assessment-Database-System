class RrkQuizzesController < ApplicationController
  before_action :set_rrk_quiz, only: %i[show edit update destroy]

  # GET /rrk_quizzes
  # GET /rrk_quizzes.json
  def index
    @rrk_quizzes = RrkQuiz.all
  end

  # GET /rrk_quizzes/1
  # GET /rrk_quizzes/1.json
  def show
    render
  end

  # GET /rrk_quizzes/new
  def new
    @rrk_quiz = RrkQuiz.new
  end

  # GET /rrk_quizzes/1/edit
  def edit
    render
  end

  # POST /rrk_quizzes
  # POST /rrk_quizzes.json
  def create
    @rrk_quiz = RrkQuiz.new(rrk_quiz_params)

    respond_to do |format|
      if @rrk_quiz.save
        format.html { redirect_to @rrk_quiz, notice: 'An RRK Quiz was successfully created.' }
        format.json { render :show, status: :created, location: @rrk_quiz }
      else
        format.html { render :new }
        format.json { render json: @rrk_quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rrk_quizzes/1
  # PATCH/PUT /rrk_quizzes/1.json
  def update
    respond_to do |format|
      if @rrk_quiz.update(rrk_quiz_params)
        format.html { redirect_to @rrk_quiz, notice: 'An RRK Quiz was successfully updated.' }
        format.json { render :show, status: :ok, location: @rrk_quiz }
      else
        format.html { render :edit }
        format.json { render json: @rrk_quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rrk_quizzes/1
  # DELETE /rrk_quizzes/1.json
  def destroy
    @rrk_quiz.destroy
    respond_to do |format|
      format.html { redirect_to rrk_quizzes_url, notice: 'An RRK Quiz was successfully destroyed.' }
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
  # and utilizes it to insert data into the RRK Quizzes relation.
  # params: a .xlsx file.
  def upload
    RrkQuiz.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_rrk_quiz
    ids = params[:id].split(',')
    @rrk_quiz = RrkQuiz.find_by(course_id: ids[0], course_discipline: ids[1],
                                rrk_quiz_version: ids[2])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def rrk_quiz_params
    params.require(:rrk_quiz).permit(:active_quiz?, :course_id, :course_discipline,
                                     :rrk_quiz_version, :quiz_creator,
                                     :total_number_of_questions)
  end
end