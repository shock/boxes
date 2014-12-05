class ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  # GET /things.json
  def index
    if params[:query]
      @things = Thing.where("name iLIKE '%#{params[:query].gsub('*', '%')}%' OR description iLIKE '%#{params[:query].gsub('*', '%')}%'")
    else
      @things = Thing.root.descendants
    end
    @things.order!(:parent_id)
  end

  # GET /things/1
  # GET /things/1.json
  def show
  end

  # GET /things/new
  def new
    @thing = Thing.new
    @thing.parent_id = params[:parent_id]
    @containers = Thing.root.descendants
  end

  # GET /things/1/edit
  def edit
    @thing = Thing.find(params[:id])
    @containers = Thing.root.descendants
  end

  # POST /things
  # POST /things.json
  def create
    @thing = Thing.new(thing_params)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to @thing, notice: 'Thing was successfully created.' }
        format.json { render :show, status: :created, location: @thing }
      else
        format.html { render :new }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /things/1
  # PATCH/PUT /things/1.json
  def update
    respond_to do |format|
      if @thing.update(thing_params)
        format.html { redirect_to @thing, notice: 'Thing was successfully updated.' }
        format.json { render :show, status: :ok, location: @thing }
      else
        format.html { render :edit }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /things/1
  # DELETE /things/1.json
  def destroy
    @thing.destroy
    respond_to do |format|
      format.html { redirect_to things_url, notice: 'Thing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def toggle_marked
    @thing = Thing.find(params[:id])
    @thing.update_attributes!( :marked=>!@thing.marked )
    render text: "OK", status: 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_thing
      @thing = Thing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def thing_params
      params.require(:thing).permit(:name, :parent_id, :description, :acquired_on, :cost, :value)
    end
end
