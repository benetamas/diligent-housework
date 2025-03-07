##
# This class responsible to process movies list
class MoviesClient

  class BadRequestError < StandardError; end
  class CommunicationError < StandardError; end

  BASE_URL = "https://api.themoviedb.org/3/search/movie"

  attr_reader :query_string, :page, :data_source

  def initialize(query_string, page_number = 1)
    @query_string = query_string.to_s
    @page = calculate_page(page_number)
    @data_source = 'cache'
  end

  def query_string=(string)
    @query_string = string.to_s
  end

  def page=(page_number)
    @page = calculate_page(page_number)
  end

  def search
    expired_at = 2.minutes

    data_from_cache = true

    data = Rails.cache.fetch(cache_key('page'), expires_in: expired_at) do
      data_from_cache = false
      get_movies_data_from_server
    end

    if data_from_cache
      hit = Rails.cache.fetch(cache_key('hit'), expires_in: expired_at) { -1 }
      Rails.cache.write(cache_key('hit'), hit + 1)
    else # data_from_server
      Rails.cache.write(cache_key('hit'), 0)
    end

    Movies.load_by_response_json(data)
  end

  def hit_count
    Rails.cache.read(cache_key('hit'))
  end

  def get_movies_data_from_server
    Rails.logger.debug "Fetch from API, query: #{normalized_query_string}"
    @data_source = 'API'
    response = RestClient::Request.execute(method: :get, url: BASE_URL, headers: {
      Authorization: calculate_authorization_param,
      params: calculate_api_params
    })
    JSON.parse(response)
  rescue RestClient::BadRequest => e
    Rails.logger.error e.message
    raise BadRequestError
  rescue => e
    Rails.logger.error e.message
    raise CommunicationError
  end

  def calculate_authorization_param
    "Bearer #{Rails.application.credentials.api_read_access_token}"
  end

  def calculate_api_params
    {
      query: normalized_query_string,
      include_adult: false,
      language: 'en-US',
      page: page
    }
  end

  def cache_key(type)
    [ normalized_query_string, type, page ].join('/')
  end

  def normalized_query_string
    query_string.scan(/\S+/).sort.join(" ")
  end

  private

  def calculate_page(page)
    if page.to_i == 0
      1
    else
      page.to_i
    end
  end

end
