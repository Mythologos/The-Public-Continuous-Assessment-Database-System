class TaxonomiesController < ApplicationController
  before_action :set_taxonomy, only: %i[show edit update destroy]

  # GET /taxonomies
  # GET /taxonomies.json
  def index
    @taxonomies = Taxonomy.all
  end

  # GET /taxonomies/1
  # GET /taxonomies/1.json
  def show
    render
  end

  # GET /taxonomies/new
  def new
    @taxonomy = Taxonomy.new
  end

  # GET /taxonomies/1/edit
  def edit
    render
  end

  # POST /taxonomies
  # POST /taxonomies.json
  def create
    @taxonomy = Taxonomy.new(taxonomy_params)

    respond_to do |format|
      if @taxonomy.save
        format.html { redirect_to @taxonomy, notice: 'A taxonomy was successfully created.' }
        format.json { render :show, status: :created, location: @taxonomy }
      else
        format.html { render :new }
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxonomies/1
  # PATCH/PUT /taxonomies/1.json
  def update
    respond_to do |format|
      if @taxonomy.update(taxonomy_params)
        format.html { redirect_to @taxonomy, notice: 'A taxonomy was successfully updated.' }
        format.json { render :show, status: :ok, location: @taxonomy }
      else
        format.html { render :edit }
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxonomies/1
  # DELETE /taxonomies/1.json
  def destroy
    @taxonomy.destroy
    respond_to do |format|
      format.html { redirect_to taxonomies_url, notice: 'A taxonomy was successfully destroyed.' }
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
  # utilizes it to insert or update data in the Taxonomies relation.
  # params: a .xlsx file.
  def upload
    Taxonomy.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def taxonomy_params
    params.require(:taxonomy).permit(:taxonomic_description, :taxonomic_id, :taxonomic_name)
  end
end
