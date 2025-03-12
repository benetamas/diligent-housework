require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /" do

    context 'accept html' do

      it "returns http success" do
        headers = { "ACCEPT" => "text/html" }
        get "/", headers: headers

        expect(response).to render_template('dashboard/index')
        expect(response).to render_template('dashboard/movies')
        expect(response).to have_http_status(:success)
      end
    end

  end

end
