class KnowledgeTopicsController < ApplicationController
  before_action :set_knowledge_topic, only: %i[show edit update destroy]

  # GET /knowledge_topics
  # GET /knowledge_topics.json
  def index
    @knowledge_topics = KnowledgeTopic.all
  end

  # GET /knowledge_topics/1
  # GET /knowledge_topics/1.json
  def show
    render
  end

  # GET /knowledge_topics/new
  def new
    @knowledge_topic = KnowledgeTopic.new
  end

  # GET /knowledge_topics/1/edit
  def edit
    render
  end

  # POST /knowledge_topics
  # POST /knowledge_topics.json
  def create
    @knowledge_topic = KnowledgeTopic.new(knowledge_topic_params)

    respond_to do |format|
      if @knowledge_topic.save
        format.html { redirect_to @knowledge_topic, notice: 'A knowledge topic was successfully created.' }
        format.json { render :show, status: :created, location: @knowledge_topic }
      else
        format.html { render :new }
        format.json { render json: @knowledge_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /knowledge_topics/1
  # PATCH/PUT /knowledge_topics/1.json
  def update
    respond_to do |format|
      if @knowledge_topic.update(knowledge_topic_params)
        format.html { redirect_to @knowledge_topic, notice: 'A knowledge topic was successfully updated.' }
        format.json { render :show, status: :ok, location: @knowledge_topic }
      else
        format.html { render :edit }
        format.json { render json: @knowledge_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /knowledge_topics/1
  # DELETE /knowledge_topics/1.json
  def destroy
    @knowledge_topic.destroy
    respond_to do |format|
      format.html { redirect_to knowledge_topics_url, notice: 'A knowledge topic was successfully destroyed.' }
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
  # and utilizes it to insert or update data in the Knowledge Topics relation.
  # params: a .xlsx file.
  def upload
    KnowledgeTopic.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_knowledge_topic
    @knowledge_topic = KnowledgeTopic.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def knowledge_topic_params
    params.require(:knowledge_topic).permit(:active_topic?, :kt_area, :kt_id,
                                            :kt_name, :kt_unit, :year_added)
  end
end