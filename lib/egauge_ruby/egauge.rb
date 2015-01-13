require 'rubygems'
require 'rest-client'
require 'json'
require 'awesome_print'
require 'pry'
require 'nokogiri'

module EgaugeRuby
  class Register
    attr_accessor :timestamp, :name, :type, :value

    def initialize(config = {})
      @timestamp      = config[:timestamp]
      @name           = config[:name]
      @type           = config[:type]
      @value          = config[:value]
    end

    def to_hash
      hash = {}
      hash[:timestamp]  = timestamp
      hash[:name]       = name
      hash[:type]       = type
      hash[:value]      = value
      hash
    end
  end

# Fetches the current measurements for all 'registers'
# parse the XML returned into one or more ruby objects
#
# record the time and the value and the category of
# the measurement(s)
#
# convert measurements into a human readable form with a unit
# export into a common data serialization format such as JSON
#
# want to get the measurements for the last 24 hours
# want to calculate totals and maybe averages?

  class Egauge
    # maybe rename Egauge to Request ??

    # Outcomes
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
    #
    attr_accessor :url, :query_arguments, :registers,
                  :document, :timestamp

    def initialize(url, query_arguments=[])
      @url, @query_arguments  = url, query_arguments
      @document               = parse(get_current)
      @timestamp              = Time.at(document.xpath('//ts').text.to_i)
      @registers              = []

      set_registers
    end

    # Get the current values for all registers defined
    #
    # 1. loops through the registers
    # 2. converts the values to something sensible
    # 3. appends the each attriubute to a hash with name as key
    # 4. returns the hash

    def current
      parse(get_current)
    end

    def get_current
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

    def set_registers
      register_collection = document.xpath('//r')
      register_collection.each { |reg| create_register_obj(reg)}
    end

    def create_register_obj(reg)
      new_reg = EgaugeRuby::Register.new(register_to_hash(reg))
      add_register(new_reg)
    end

    def add_register(reg)
      registers.push(reg)
    end

    def register_to_hash(reg)
      hash = {}
      hash[:timestamp]  = timestamp
      hash[:name]       = reg.attributes["n"].value
      hash[:type]       = reg.attributes["t"].value
      hash[:value]      = reg.children.text.to_i
      hash
    end
  end
end
