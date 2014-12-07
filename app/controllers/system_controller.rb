class SystemController < ApplicationController
  def example_layout
    render :text => '', :layout => "example"
  end
end