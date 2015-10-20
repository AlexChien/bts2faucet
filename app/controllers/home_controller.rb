class HomeController < ApplicationController
  def index
    render :file => "public/index.html.home"
  end
end
