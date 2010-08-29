#!/usr/bin/env jruby
# encoding: utf-8

require 'sinatra'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

class Bagatela < Sinatra::Base

  disable :raise_errors, :show_exceptions

  before do
    content_type :json
  end

  post '/*:*' do
    raise BadRequest, "two_different_stops_required" if params[:splat][0] == params[:splat][1]

    Neo4j::Transaction.run do
      from, to = params[:splat].map do |stop|
        Stop.find(:name=>stop.downcase)
      end

      raise NotFound, "resource_not_found" if from.size == 0 or to.size == 0
    end
    [:foo => "bar"].to_json
  end

  error do
    e = env['sinatra.error']
    error e.respond_to?(:status) ? e.status : 500, {"error" => e.underscore, "reason" => e.message}.to_json
  end
end