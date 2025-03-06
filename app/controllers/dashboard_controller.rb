class DashboardController < ApplicationController
  def index
    set_variables

    respond_to do |format|
      format.html
      format.js
    end
  rescue MoviesClient::CommunicationError
    flash[:alert] = "Communication error with movies db API. Please try again later."
    render template: "dashboard/error"
  end

  private

  def set_variables
    @params = OpenStruct.new(params)
    if @params.query.present?
      @client = MoviesClient.new(@params.query, @params.page)
      @movies = @client.search
    end
  end

end
