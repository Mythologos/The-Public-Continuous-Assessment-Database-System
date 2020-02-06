class QuestionTopicMappingsController < ApplicationController
  before_action :set_question_topic_mapping, only: %i[show edit update destroy]

  # GET /question_topic_mappings
  # GET /question_topic_mappings.json
  def index
    @question_topic_mappings = QuestionTopicMapping.all
  end

  # GET /question_topic_mappings/1
  # GET /question_topic_mappings/1.json
  def show
    render
  end

  # GET /question_topic_mappings/new
  def new
    @question_topic_mapping = QuestionTopicMapping.new
  end

  # GET /question_topic_mappings/1/edit
  def edit
    render
  end

  # POST /question_topic_mappings
  # POST /question_topic_mappings.json
  def create
    @question_topic_mapping = QuestionTopicMapping.new(question_topic_mapping_params)

    respond_to do |format|
      if @question_topic_mapping.save
        format.html { redirect_to @question_topic_mapping, notice: 'A Question-Topic mapping was successfully created.' }
        format.json { render :show, status: :created, location: @question_topic_mapping }
      else
        format.html { render :new }
        format.json { render json: @question_topic_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /question_topic_mappings/1
  # PATCH/PUT /question_topic_mappings/1.json
  def update
    respond_to do |format|
      if @question_topic_mapping.update(question_topic_mapping_params)
        format.html { redirect_to @question_topic_mapping, notice: 'A Question-Topic mapping was successfully updated.' }
        format.json { render :show, status: :ok, location: @question_topic_mapping }
      else
        format.html { render :edit }
        format.json { render json: @question_topic_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_topic_mappings/1
  # DELETE /question_topic_mappings/1.json
  def destroy
    @question_topic_mapping.destroy
    respond_to do |format|
      format.html { redirect_to question_topic_mappings_url, notice: 'A Question-Topic mapping was successfully destroyed.' }
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
  # and utilizes it to insert data into the Question-Topic Mappings relation.
  # params: a .xlsx file.
  def upload
    QuestionTopicMapping.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_question_topic_mapping
    ids = params[:id].split(',')
    @question_topic_mapping = QuestionTopicMapping.find_by(kt_id: ids[0], question_id: ids[1])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def question_topic_mapping_params
    params.require(:question_topic_mapping).permit(:question_id, :kt_id)
  end
end
