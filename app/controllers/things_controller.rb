class ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  # GET /things.json
  def index
    respond_to do |format|
      @query = params[:query].squish.downcase if params[:query].present?
      if @query || params[:marked_only].present?
        @things = cached_query(params)
      else
        redirect_to Thing.world and return
      end

      format.html {
        process_recent_searches(params)
      }
      process_json_request(format) do
        self.formats << :html
        json_response.html = render_to_string partial: 'things/thing_index'
        json_response.data.selected_ids = @things.map(&:id)
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

  def bulk_update
    thing_ids = params[:selected_ids]
    verb = params[:verb]
    case verb
    when "move"
      new_parent = Thing.find(params[:parent_id])
      Thing.transaction do
        @things = Thing.where(id: thing_ids)
        @things.each do |thing|
          thing.update!(parent: new_parent)
        end
        respond_to do |format|
          process_json_request(format) do
          end
          format.html do
            flash[:success] = "#{@things.count} objects moved into #{new_parent.name}."
            redirect_to :back
          end
        end
      end
    when "unmark-selected"
      Thing.transaction do
        @things = Thing.where(id: thing_ids)
        @things.each do |thing|
          thing.marked = false
          thing.save!
        end
        respond_to do |format|
          process_json_request(format) do
          end
          format.html do
            flash[:success] = "#{@things.count} objects have been unmarked."
            redirect_to :back
          end
        end
      end
    when "destroy-selected"
      Thing.transaction do
        @things = Thing.where(id: thing_ids)
        @things.each do |thing|
          thing.children.each do |child|
            child.update!(parent: Thing.orphaned)
          end
          thing.destroy
        end
        respond_to do |format|
          process_json_request(format) do
          end
          format.html do
            flash[:success] = "#{@things.count} objects have been destroyed."
            redirect_to :back
          end
        end
      end
    when "add-tags"
      tag_ids = (params.delete(:tag_ids) || "").split(',')
      thing_ids.each do |thing_id|
        tag_ids.each do |tag_id|
          if ThingTag.where(:tag_id => tag_id, :thing_id => thing_id).empty?
            ThingTag.create(:tag_id => tag_id, :thing_id => thing_id)
          end
        end
      end
      respond_to do |format|
        process_json_request(format) do
        end
        format.html do
          flash[:success] = "Tags have been added."
          redirect_to :back
        end
      end
    when "remove-tags"
      tag_ids = (params.delete(:tag_ids) || "").split(',')
      thing_ids.each do |thing_id|
        tag_ids.each do |tag_id|
          ThingTag.where(:tag_id => tag_id, :thing_id => thing_id).destroy_all
        end
      end
      respond_to do |format|
        process_json_request(format) do
        end
        format.html do
          flash[:success] = "Tags have been removed."
          redirect_to :back
        end
      end
    else
      raise "Unknown bulk_update verb: #{verb}"
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
    ThingTag.where(:thing_id => @thing.id).destroy_all
    tag_ids.each do |tag_id|
      ThingTag.create!(:tag_id => tag_id, :thing => @thing)
    end
  end

  def things_query_cache_key(params)
    cache_key = ["things_query_v1"]
    cache_key << params[:query]
    cache_key << params[:search_tags].present?
    cache_key << params[:marked_only].present?
    cache_key << Thing.world.updated_at.to_s
    cache_key = cache_key.map(&:to_s).join(" • ")
  end
  helper_method :things_query_cache_key

  def cached_query(params)
    cache_key = things_query_cache_key(params)
    @search = true
    @things = []
    @marked_things_only = !@query
    params[:search_tags] = true if params[:search_tags]
    @things = Rails.cache.fetch(cache_key) do
      if @query
        if params[:search_tags]
          tags = Tag.where(name: @query.split(/[^\w]/).map(&:squish).map(&:downcase)).all
          @things += tags.map(&:things).flatten
        else
          @things += Thing.root.descendants.where("name iLIKE '%#{@query.gsub('*', '%')}%' OR description iLIKE '%#{@query.gsub('*', '%')}%'")
        end
        @things = @things.select{|t| t.marked} if params[:marked_only]
        @things = @things.uniq
        @things = @things.sort_by(&:name)
      else
        @things = Thing.marked.order(:name).all
      end
    end
  end


end
