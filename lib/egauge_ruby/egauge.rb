require 'rubygems'
require 'rest-client'
require 'json'
require 'awesome_print'
require 'pry'
require 'nokogiri'

module EgaugeRuby
  class Egauge

    ## Outcomes
    # want to fetch the current measurements for all 'registers'
    # parse the XML returned into one or more ruby objects
    #
    # want to record the time and the value and the category of
    # the measurement(s)
    #
    # convert measurements into a human readable form with a unit
    # export into a common data serialization format such as JSON
    #
    # want to get the measurements for the last 24 hours
    # want to calculate totals and maybe averages?
    ##

    def current
      parse(get_current)
    end

    def get_current
      url = "http://22north.egaug.es/cgi-bin/egauge"
      RestClient.get(url) do |response, request, result, &block|
        case response.code
        when 200
          response
        else
          response.return!(request, result, &block)
        end
      end
    end

    def parse(response)
      Nokogiri::XML(response)
    end
  end
end
