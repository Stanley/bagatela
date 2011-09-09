#!/usr/bin/env jruby
# encoding: utf-8

require 'sinatra'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

class RestApi < Sinatra::Base

  disable :raise_errors, :show_exceptions
  include Bagatela::Graph

  before do
    content_type :json
  end
  
  # Welcome message
  get '/' do 
    {:message => 'Welcome aboard!', :version => REVISION}.to_json
  end

  # Example POST /2011-08-31/node/123/connection
  post /^\/(\d{4}-\d{2}-\d{2})\/node\/(\d+)\/connection/ do |date, start|

    Neo4j::Config[:storage_path] = date

    params = JSON.parse request.body.read
    to = /node\/(\d+)/.match(params['to']) || raise("fail")
    time = Time.parse(params['start_at'])
    from = Neo4j::Node.load start
    to = Neo4j::Node.load to[1]
    journey = Search::Fast.journey(from: from, to: to, time: time)

    JSON.pretty_generate({ 
      #:start => from.uri,
      :nodes => journey.nodes,
      :departures => journey.departures_details,
      :length => journey.length,
      :arrival => journey.arrival
      #:end => to.uri
    })
  end

  error do
    e = env['sinatra.error']
    error e.respond_to?(:status) ? e.status : 500, {"error" => e.underscore, "message" => e.message}.to_json
  end
end
