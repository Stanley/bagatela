#!/usr/bin/env jruby
# encoding: utf-8

require 'sinatra'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

class Bagatela < Sinatra::Base

  disable :show_exceptions, :raise_errors

  before do
    content_type :json
    @result = {}
  end

  post '/*:*' do
    raise BadRequest, "two_different_stops_required" if params[:splat][0] == params[:splat][1]
    Neo4j::Transaction.run do
      #
      from, to = params[:splat]
      # Distance we've traveled so far
      distance = 0
      #
      stop = {}
      # Output - Array of Hashes which describes our trip
      results = []                        
      # Initial time
      time = params['time'] ? Time.parse(params['time']) : Time.new
      # What we optimize for
      discriminant = params['priority'] || 'dist'
      # Time we measure during trip (in minutes from 00:00)
#      currently = now.hour*60 + now.min
     
      path = AStar.new(from, to, time, discriminant)
      path.each_run do |departure, stop_a, duration, stop_b|

        stop["stop"] ||= stop_a
        stop["departure"] = departure.strftime("%H:%M")
        results.push stop

        stop = {'stop'    => stop_b,
                'arrival' => Time.at(departure + duration*60).strftime("%H:%M") }
      end

      if results.empty?
        @result[:from]  = from
        @result[:to]    = to
        raise NotFound, 'no_connection'
      end
      
      @result[:from]  = results.first['stop']
      @result[:to]    = stop['stop']

      arrival = stop['arrival'].split(':').map{|x|x.to_i}
      @result[:duration] = (arrival[0]-time.hour)*60 + arrival[1]-time.min
      @result[:distance] = nil #distance
      @result[:results]  = results << stop
      @result.to_json
    end    
  end

  error do
    e = env['sinatra.error']
    error e.respond_to?(:status) ? e.status : 500, @result.merge({"error" => e.underscore, "reason" => e.message}).to_json
  end
end
