class DashboardController < ApplicationController
  def index
    set_variables

    respond_to do |format|
      format.html
      format.js
    end
  rescue => e
    case e
    when MoviesClient::CommunicationError
      flash[:alert] = "Communication error with movies db API. Please try again later."
    when MoviesClient::BadRequestError
      flash[:alert] = "'Bad request' response from movies db API. Please try again."
    end
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render template: "dashboard/error" }
    end
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
