class InstructionsController < ApplicationController
  before_action :set_instruction, only: %i[show edit update destroy]

  # GET /instructions
  # GET /instructions.json
  def index
    @instructions = Instruction.all
  end

  # GET /instructions/1
  # GET /instructions/1.json
  def show
    render
  end

  # GET /instructions/new
  def new
    @instruction = Instruction.new
  end

  # GET /instructions/1/edit
  def edit
    render
  end

  # POST /instructions
  # POST /instructions.json
  def create
    @instruction = Instruction.new(instruction_params)

    respond_to do |format|
      if @instruction.save
        format.html { redirect_to @instruction, notice: 'An instruction was successfully created.' }
        format.json { render :show, status: :created, location: @instruction }
      else
        format.html { render :new }
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructions/1
  # PATCH/PUT /instructions/1.json
  def update
    respond_to do |format|
      if @instruction.update(instruction_params)
        format.html { redirect_to @instruction, notice: 'An instruction was successfully updated.' }
        format.json { render :show, status: :ok, location: @instruction }
      else
        format.html { render :edit }
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructions/1
  # DELETE /instructions/1.json
  def destroy
    @instruction.destroy
    respond_to do |format|
      format.html { redirect_to instructions_url, notice: 'An instruction was successfully destroyed.' }
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
  # and utilizes it to insert or update data in the Instructions relation.
  # params: a .xlsx file.
  def upload
    Instruction.upload(params[:xlsx_file])
    redirect_to controller: :pages, action: :home
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_instruction
    ids = params[:id].split(',')
    @instruction = Instruction.find_by(kt_id: ids[0], course_id: ids[1],
                                       course_discipline: ids[2])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def instruction_params
    params.require(:instruction).permit(:course_id, :course_discipline,
                                        :kt_id, :mapping_relationship)
  end
end