class RestaurantsController < ApplicationController
  def index
    render 'index'
  end

  def search
    params[:query] = '猫' if params[:query].blank?
    query = params[:query]
    search = Tire.search 'nico2/video' do
      query do
        string "#{query}", :default_operator => 'AND', :use_dis_max => true
      end

      facet 'tags' do
        terms :tag
      end
    end

    @results = search

    render 'search'
  end

  def timeline
    params[:query] = '猫' if params[:query].blank?
    query = params[:query]
    search = Tire.search 'nico2/comment' do
      query do
        string "#{query}", :default_operator => 'AND', :use_dis_max => true
      end

      facet('timeline') { date :date, :interval => 'day' }
    end
    
    @results = search
    data_table = GoogleVisualr::DataTable.new

    # Add Column Headers 
    data_table.new_column('string', '' ) 
    data_table.new_column('number', 'コメント数') 

    # Add Rows and Values 
    #
    data = @results.results.facets['timeline']['entries'].map do |entry|
      [Time.at(entry['time']/1000).strftime("%Y-%m-%d"), entry['count']]
    end

    data_table.add_rows(data) 
    option = { width: 800, height: 240, title: '' }
    @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, option)

    render 'timeline'
  end
end
