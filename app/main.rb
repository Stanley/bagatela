#!/usr/bin/env jruby
# encoding: utf-8

require 'sinatra'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

class Bagatela < Sinatra::Base
  post '/*:*' do
    from, to = params[:splat]

    stops = []
    Neo4j::Transaction.run do
      Stop.find(:name=>from.downcase).each do |stop|
        stops << "#{stop.name} (#{stop.location})"
      end
    end
    stops.join(", ")    
  end
end
