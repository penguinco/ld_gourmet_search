# -*- coding: utf-8 -*-
require 'rubygems'
require 'csv'

gourmet = Tire::Index.new('livedoor_gourmet')

categories = {}
CSV.foreach("data/ldgourmet/categories.csv", :encoding => 'U', :headers => true, :header_converters => :symbol) do |row|
  categories[row[:id]] = row[:name]
end

restaurants = []
CSV.foreach("data/ldgourmet/restaurants.csv", :encoding => 'U', :headers => true, :header_converters => :symbol) do |row|
  category_names = []
  [:category_id1, :category_id2, :category_id3, :category_id4, :category_id5].each do |category|
    category_names << categories[row[category]]
  end
  restaurants << {
    :id           => row[:id].to_i,  
    :name         => [row[:name], row[:alphabet], row[:name_kana]].join(' '),
    :category     => category_names.join(' '),
    :address      => row[:address],
    :location     => [row[:north_latitude].to_f, row[:east_longitude].to_f],
    :description  => row[:description],
    :purpose      => row[:purpose],
    :photo_count  => row[:photo_count].to_i,
    :menu_count   => row[:menu_count].to_i,
    :access_count => row[:access_count].to_i,
    :closed       => row[:closed].to_i,
    :type         => 'restaurant'
  }
end

Tire.index 'livedoor_gourmet' do
  restaurants.in_groups_of(500, false).each do |_restaurants|
    puts _restaurants.first
    import _restaurants
  end
end
