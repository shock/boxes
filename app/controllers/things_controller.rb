class ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  # GET /things.json
  def index
    if query = params[:query]
      query = query.squish
      @things = Thing.where("name iLIKE '%#{query.gsub('*', '%')}%' OR description iLIKE '%#{query.gsub('*', '%')}%'")
    elsif params[:node]
      @thing = Thing.find(params[:node])
      render json: @thing.to_builder.target!
    else
      redirect_to Thing.world and return
    end
    @things.order!(:parent_id)
  end

  def name_search
    respond_to do |format|
      format.json do
        query = params[:query]
        render(json: []) and return unless query.present?
        matches = Thing.find_by_prefix(query)
        matches += Noun.find_by_prefix(query)
        render json: matches.uniq
      end
    end
  end

  def tree
    respond_to do |format|
      format.json do
        if params[:node]
          @thing = Thing.find_by_id(params[:node])
          render json: @thing.children_to_builder.target!
        else
          @thing = Thing.find_by_id(params[:current]) || Thing.root
          render json: @thing.parents_to_builder.target!
        end
      end
    end
  end

  # GET /things/1
  # GET /things/1.json
  def show
    respond_to do |format|
      format.html {}
      format.json do
        render :json => @thing.to_builder.target!
      end
    end
  end

  # GET /things/new
  def new
    @thing = Thing.new
    @thing.parent_id = params[:parent_id]
    @containers = Thing.root.descendants
    render :new, layout: false
  end

  # GET /things/1/edit
  def edit
    @thing = Thing.find(params[:id])
    @containers = Thing.root.descendants
    render :edit, layout: false
  end

  # POST /things
  # POST /things.json
  def create
    @thing = Thing.new(thing_params)

    respond_to do |format|
      if @thing.save
        format.html { redirect_to :back, notice: 'Thing was successfully created.' }
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
        format.html { redirect_to :back, notice: 'Thing was successfully updated.' }
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
      format.html { redirect_to :back, notice: 'Thing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def toggle_marked
    @thing = Thing.find(params[:id])
    @thing.update_attributes!( :marked=>!@thing.marked )
    respond_to do |format|
      format.js {}
    end
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
