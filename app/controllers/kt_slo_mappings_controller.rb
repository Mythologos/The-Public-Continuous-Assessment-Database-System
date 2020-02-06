class KtSloMappingsController < ApplicationController
  before_action :set_kt_slo_mapping, only: %i[show edit update destroy]

  # GET /kt_slo_mappings
  # GET /kt_slo_mappings.json
  def index
    @kt_slo_mappings = KtSloMapping.all
  end

  # GET /kt_slo_mappings/1
  # GET /kt_slo_mappings/1.json
  def show
    render
  end

  # GET /kt_slo_mappings/new
  def new
    @kt_slo_mapping = KtSloMapping.new
  end

  # GET /kt_slo_mappings/1/edit
  def edit
    render
  end

  # POST /kt_slo_mappings
  # POST /kt_slo_mappings.json
  def create
    @kt_slo_mapping = KtSloMapping.new(kt_slo_mapping_params)

    respond_to do |format|
      if @kt_slo_mapping.save
        format.html { redirect_to @kt_slo_mapping, notice: 'A KT-SLO mapping was successfully created.' }
        format.json { render :show, status: :created, location: @kt_slo_mapping }
      else
        format.html { render :new }
        format.json { render json: @kt_slo_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kt_slo_mappings/1
  # PATCH/PUT /kt_slo_mappings/1.json
  def update
    respond_to do |format|
      if @kt_slo_mapping.update(kt_slo_mapping_params)
        format.html { redirect_to @kt_slo_mapping, notice: 'A KT-SLO mapping was successfully updated.' }
        format.json { render :show, status: :ok, location: @kt_slo_mapping }
      else
        format.html { render :edit }
        format.json { render json: @kt_slo_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kt_slo_mappings/1
  # DELETE /kt_slo_mappings/1.json
  def destroy
    @kt_slo_mapping.destroy
    respond_to do |format|
      format.html { redirect_to kt_slo_mappings_url, notice: 'A KT-SLO mapping was successfully destroyed.' }
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
  # and utilizes it to insert data into the KT-SLO Mappings relation.
  # params: a .xlsx file.
  def upload
    KtSloMapping.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_kt_slo_mapping
    ids = params[:id].split(',')
    @kt_slo_mapping = KtSloMapping.find_by(kt_id: ids[0], slo_id: ids[1])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def kt_slo_mapping_params
    params.require(:kt_slo_mapping).permit(:kt_id, :slo_id)
  end
end