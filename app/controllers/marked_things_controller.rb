class MarkedThingsController < ApplicationController

  def index
    @things = Thing.marked.order(:lft).all
  end

  def move
    new_parent = Thing.find(params[:parent_id])
    Thing.transaction do
      @things = Thing.marked.order(:lft).all
      @things.each do |thing|
        thing.update!(parent: new_parent)
      end
      flash[:success] = "#{@things.count} objects moved into #{new_parent.name}."
    end
    redirect_to :back
  end

  def clear
    @things = Thing.marked
    Thing.transaction do
      @things.each {|t| t.update!(marked: false)}
      flash[:success] = "All objects unselected"
    end
    redirect_to :back
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
      flash[:success] = "All selected objects destroyed"
    end
    redirect_to :back
  end
end