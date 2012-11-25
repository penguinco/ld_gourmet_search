class RestaurantsController < ApplicationController
  def index
    render 'index'
  end

  def search
    query = params[:query]
    search = Tire.search 'livedoor_gourmet/restaurant' do
      query do
        string "#{query}", :default_operator => 'AND', :use_dis_max => true
      end

      filter :term, :closed => '0'
      sort { by :access_count, 'desc' }
    end

    @results = search.results

    render 'search'
  end

  def review_search
    query = params[:query]
    search = Tire.search 'livedoor_gourmet/rating' do
      query do
        string "#{query}", :default_operator => 'AND', :use_dis_max => true
      end

      facet 'restaurant_ids' do
        terms :restaurant_id
      end
    end

    @results = []
    search.results.facets['restaurant_ids']['terms'].each do |restaurant|
      restaurant_info = Tire.search('livedoor_gourmet/restaurant') { query { string "id:#{restaurant['term']}" } }.results.first

      reviews = Tire.search 'livedoor_gourmet/rating' do
        query do
          string "body:#{query}", :default_operator => 'AND', :use_dis_max => true
        end
        size 2
        filter :term, :restaurant_id => restaurant['term'].to_i
        highlight :body => {"fragment_size" => 50, "number_of_fragments" => 2}
      end.results

      @results << {:restaurant => restaurant_info,
                   :rating_count => restaurant['count'],
                   :reviews => reviews
                  }
    end
    render 'review_search'
  end
end
