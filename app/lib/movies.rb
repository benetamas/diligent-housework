class Movies

  include Enumerable

  attr_reader :page, :total_pages, :total_results

  def initialize(page, total_pages, total_results, results)
    @page = page
    @total_pages = total_pages
    @total_results = total_results
    @results = results.map(&Movie.method(:new))
  end

  def each
    @results.each { yield _1 }
  end

  def inspect
    "<Movies @page=#{@page}, @total_pages=#{@total_pages} @total_results=#{@total_results}>"
  end

  def size
    count
  end

  def pagination
    Kaminari.paginate_array(to_a, total_count: total_results).page(page).per(20)
  end

  class << self

    def load_by_response_json(json)
      new(json['page'], json['total_pages'], json['total_results'], json['results'])
    end

  end

end