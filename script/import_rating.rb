# -*- coding: utf-8 -*-
require 'rubygems'
require 'csv'

gourmet = Tire::Index.new('livedoor_gourmet')


ratings = []

CSV.foreach("data/ldgourmet/ratings.csv", :encoding => 'U', :headers => true, :header_converters => :symbol) do |row|
  ratings << {
    :id               => row[:id].to_i,  
    :restaurant_id    => row[:restaurant_id].to_i,  
    :total            => row[:total].to_i,  
    :food             => row[:food].to_i,  
    :service          => row[:service].to_i,  
    :atmosphere       => row[:atmosphere].to_i,  
    :cost_performance => row[:cost_performance].to_i,
    :title            => row[:title],
    :body             => row[:body],
    :purpose          => row[:purpose],
    :type             => 'rating'
  }
end

Tire.index 'livedoor_gourmet' do
  ratings.in_groups_of(500, false).each do |_ratings|
    puts "updating 500 ratings"
    puts _ratings.first[:body]
    import _ratings
  end
end
