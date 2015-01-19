class ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  # GET /things.json
  def index
    query = params[:query] if params[:query].present?
    @tag_list = params[:tags] if params[:tags].present?
    if query || @tag_list
      @search = true
      @things = []

      if @tag_list || params[:search_tags]
        params[:search_tags] = true
        @tag_list ||= query
        @tags = Tag.where(name: @tag_list.split(/[^\w]/).map(&:squish).map(&:downcase)).all
        @things += @tags.map(&:things).flatten
      else
        query = query.squish
        @things += Thing.root.descendants.where("name iLIKE '%#{query.gsub('*', '%')}%' OR description iLIKE '%#{query.gsub('*', '%')}%'")
      end
      @things = @things.uniq
    else
      redirect_to Thing.world and return
    end
    @things = @things.sort_by(&:name)
    respond_to do |format|
      format.html {
        process_recent_searches
      }
      process_json_request(format) do
        self.formats << :html
        json_response.html = render_to_string partial: 'things/thing_index'
      end
    end
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
    respond_to do |format|
      process_json_request(format) do
        begin
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
            show_node = target.parent
            node.parent_id = target.id
            if first_child = target.children.first
              node.move_to first_child, :left
            else
              node.move_to target, :child
            end
          else
            raise "unknown position: #{position}, target: #{target.name}, node: #{node.name}"
          end
          json_response.redirect_to = thing_path(target)
        rescue ActiveRecord::ActiveRecordError
          json_response.success = false
          json_response.error_messages = [$!.message]
        end
      end
    end
  end

  def tree
    respond_to do |format|
      format.json do
        if params[:node]
          @thing = Thing.find_by_id(params[:node])
          # render json: @thing.children_to_builder.target!
          render "children"
        else
          @thing = Thing.find_by_id(params[:current]) || Thing.root
          # render json: @thing.parents_to_builder.target!
          render "parents"
        end
      end
    end
  end

  # GET /things/1
  # GET /things/1.json
  def show
    respond_to do |format|
      format.html {}
      process_json_request(format) do
        self.formats << :html
        json_response.html = render_to_string partial: 'things/thing_show'
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
            redirect_to thing_path(@thing.parent)
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
    parent = @thing.parent
    parent = Thing.world if parent == Thing.root
    @thing.destroy
    respond_to do |format|
      format.html {
        redirect_to thing_path(parent)
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
    rescue
      redirect_to thing_path(Thing.world)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def thing_params
      params.require(:thing).permit(:name, :parent_id, :description, :acquired_on, :cost, :value)
    end

    def update_tags
      @thing.touch
      tag_ids = (params.delete(:tags) || "").split(',')
      ThingTag.delete_all(:thing_id => @thing.id)
      tag_ids.each do |tag_id|
        ThingTag.create!(:tag_id => tag_id, :thing => @thing)
      end
    end

    def process_recent_searches
      max_history = 10
      rs = recent_searches || []
      if params[:query].present?
        search_params = {
          "query" => params[:query],
          "search_tags" => params[:search_tags]
        }
        rs = rs - [search_params]
        rs.unshift(search_params)
        if rs.length > max_history
          rs = rs.slice(0,max_history)
        end
        self.recent_searches = rs
      end
    end

end
