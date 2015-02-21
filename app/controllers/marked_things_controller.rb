class MarkedThingsController < ApplicationController

  def index
    @things = Thing.marked.order(:lft).all
    respond_to do |format|
      format.html {}
      process_json_request(format) do
        self.formats << :html
        json_response.html = render_to_string partial: "marked_things/marked_things_index"
        json_response.data.selected_ids = @things.map(&:id)
      end
    end
  end

  def move
    new_parent = Thing.find(params[:parent_id])
    Thing.transaction do
      @things = Thing.marked.order(:lft).all
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
  end

  def clear
    @things = Thing.marked
    Thing.transaction do
      @things.each {|t| t.update!(marked: false)}
      respond_to do |format|
        process_json_request(format) do
        end
        format.html do
          flash[:success] = "All objects unselected"
          redirect_to :back
        end
      end
    end
  end

  def destroy
    @things = Thing.marked
    Thing.transaction do
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
          flash[:success] = "All selected objects destroyed"
          redirect_to :back
        end
      end
    end
  end
end