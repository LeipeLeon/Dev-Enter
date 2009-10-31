class IncomingController < ApplicationController
  def recieve
    @app = App.find_by_id(params[:id])
    @app.fill(params[:yaml])
  end
end