class ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  # GET /things.json
  def index
    if query = params[:query]
      params[:tags] = params[:query].dup
      query = query.squish
      @things = Thing.root.descendants.where("name iLIKE '%#{query.gsub('*', '%')}%' OR description iLIKE '%#{query.gsub('*', '%')}%'")
      tags = Tag.where(name: params[:tags].split(/[^\w]/).map(&:squish)).all
      @things += tags.map(&:things).flatten
      @things = @things.uniq
    elsif params[:node]
      @thing = Thing.find(params[:node])
      render json: @thing.to_builder.target!
    else
      redirect_to Thing.world and return
    end
    @things = @things.sort_by(&:lft)
  end

  def name_search
    respond_to do |format|
      format.json do
        query = params[:query]
        render(json: []) and return unless query.present?
        matches = Thing.find_by_prefix(query)
        matches += Noun.find_by_prefix(query)
        matches += Tag.find_by_prefix(query)
        render json: matches.uniq
      end
    end
  end

  def move_to
    node = Thing.find(params[:id])
    target = Thing.find(params[:target_id])
    position = params[:position]
    case position
    when 'before'
      show_node = target.parent
      node.move_to target, :left
    when 'after'
      show_node = target.parent
      node.move_to target, :right
    when 'inside'
      show_node = target
      node.parent_id = target.id
      if first_child = target.children.first
        node.move_to first_child, :left
      else
        node.move_to target, :child
      end
    else
      raise "unknown position: #{position}, target: #{target.name}, node: #{node.name}"
    end
    respond_to do |format|
      process_json_request(format) do
        json_response.redirect_to = thing_path(show_node)
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
      Thing.transaction do
        if @thing.save
          update_tags
          format.html {
            flash[:success] = 'Thing was successfully created.'
            redirect_to :back
          }
          format.json { render :show, status: :created, location: @thing }
        else
          format.html { render :new }
          format.json { render json: @thing.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /things/1
  # PATCH/PUT /things/1.json
  def update
    respond_to do |format|
      Thing.transaction do
        if @thing.update(thing_params)
          update_tags
          format.html {
            flash[:success] = 'Thing was successfully updated.'
            redirect_to :back
          }
          format.json { render :show, status: :ok, location: @thing }
        else
          format.html { render :edit }
          format.json { render json: @thing.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /things/1
  # DELETE /things/1.json
  def destroy
    @thing.destroy
    respond_to do |format|
      format.html {
        flash[:success] = 'Thing was successfully destroyed.'
        redirect_to :back
      }
      format.json { head :no_content }
    end
  end

  def toggle_marked
    @thing = Thing.find(params[:id])
    @thing.update_attributes!( :marked=>!@thing.marked )
    @marked_count = Thing.marked.count
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

    def update_tags
      tag_ids = (params.delete(:tags) || "").split(',')
      ThingTag.delete_all(:thing_id => @thing.id)
      tag_ids.each do |tag_id|
        ThingTag.create!(:tag_id => tag_id, :thing => @thing)
      end
    end
end
