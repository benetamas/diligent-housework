require 'rails_helper'

RSpec.describe MoviesClient do

  let(:client) { MoviesClient.new('test query string', 1) }

  it 'can be setting query string' do
    str = 'new query string'
    client.query_string = str
    expect(client.query_string).to eq(str)

    int = 123
    client.query_string = int
    expect(client.query_string).to eq('123')

    client.query_string = nil
    expect(client.query_string).to eq('')
  end

  it 'can be setting page' do
    int = 12
    client.page = int
    expect(client.page).to eq(int)

    str = '456'
    client.page = str
    expect(client.page).to eq(456)

    client.page = nil
    expect(client.page).to eq(1)
  end

  context 'search' do

    it 'data getting from cached successfully' do

      Rails.cache.write(client.cache_key('page'), {
        'page' => 1,
        'total_pages' => 1,
        'total_results' => 3,
        'results' => [{ 'title' => 'lethal 1', }, { 'title' => 'lethal 2' }, { 'title' => 'lethal 3' }]
      }, expires_in: 2.minutes)

      Rails.cache.write(client.cache_key('hit'), 5)

      movies = client.search

      expect(movies).to be_kind_of(Movies)
      expect(movies.size).to eq(3)
      expect(movies.first.title).to eq('lethal 1')
      expect(client.hit_count).to eq(6)
    end

    it 'data getting from server successfully' do
      Rails.cache.delete(client.cache_key('page'))

      allow(client).to receive(:get_movies_data_from_server).and_return({
                                                                          'page' => 1,
                                                                          'total_pages' => 1,
                                                                          'total_results' => 3,
                                                                          'results' => [{ 'title' => 'lethal 5', }, { 'title' => 'lethal 4' }]
                                                                        })

      movies = client.search

      expect(movies).to be_kind_of(Movies)
      expect(movies.size).to eq(2)
      expect(movies.first.title).to eq('lethal 5')
      expect(client.hit_count).to eq(0)
    end

  end

  it 'hit_count return value for "hit" cache key' do
    allow(Rails.cache).to receive(:read).with("query string test/hit/1").and_return(3)

    expect(client.hit_count).to eq(3)
  end

  context 'get_movies_data_from_server' do

    it 'return with JSON formatted API response, and setting data_source to "API' do
      client.query_string = 'lethal weapon'
      response = [{ title: 'lethal 1', }, { title: 'lethal 2' }, { title: 'lethal 3' }].to_json
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect(client.get_movies_data_from_server).to eq(JSON.parse(response))
      expect(client.data_source).to eq('API')
    end

    it 'raise MoviesClient::BadRequestError if the API response bad request' do
      allow(RestClient::Request).to receive(:execute).and_raise(RestClient::BadRequest)
      expect { client.get_movies_data_from_server }.to raise_error(MoviesClient::BadRequestError)
    end

    it 'raise MoviesClient::CommunicationError if in the API call have any error' do
      allow(RestClient::Request).to receive(:execute).and_raise('unknown exception')
      expect { client.get_movies_data_from_server }.to raise_error(MoviesClient::CommunicationError)
    end

  end

  it 'calculate_authorization_param return "Bearer " and read access token from Rails credentials' do
    allow(Rails.application.credentials).to receive(:api_read_access_token).and_return('access_token')
    expect(client.calculate_authorization_param).to eq('Bearer access_token')
  end

  it 'calculate_api_params returns params for api, included normalized query string and page' do
    expect(client.calculate_api_params).to eq({
                                                query: 'query string test',
                                                include_adult: false,
                                                language: 'en-US',
                                                page: 1
                                              })
  end

  context 'cache_key' do

    it 'with "page" `type` param' do
      expect(client.cache_key('page')).to eq('query string test/page/1')
    end

    it 'with "hit" `type` param' do
      expect(client.cache_key('hit')).to eq('query string test/hit/1')
    end

    it 'with nil `type` param' do
      expect(client.cache_key(nil)).to eq('query string test//1')
    end

  end

  it 'normalized_query_string returns sorted keywords' do
    expect(client.normalized_query_string).to eq('query string test')

    client.query_string = '   c   f  h   g   a    '
    expect(client.normalized_query_string).to eq('a c f g h')
  end

end
