require 'rubygems'
require 'rest-client'
require 'json'
require 'awesome_print'
require 'pry'
require 'nokogiri'

module EgaugeRuby
  class Register
    attr_accessor :timestamp, :name, :type, :value, :instantaneous

    def initialize(config = {})
      @timestamp      = config[:timestamp]
      @name           = config[:name]
      @type           = config[:type]
      @value          = config[:value]
      @instantaneous  = config[:instantaneous]
    end

    def to_hash
      hash = {}
      hash[:timestamp]        = timestamp
      hash[:name]             = name
      hash[:type]             = type
      hash[:value]            = value
      hash[:instantaneous]    = instantaneous
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

  class Request

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

    attr_accessor :base_url, :query_arguments, :full_url,
                  :registers, :document, :timestamp

    def initialize(base_url:, request_type: "current", query_arguments: [], config: {})
      @base_url                     = base_url || config[:base_url]
      @request_type                 = request_type || config[:request_type]
      @query_arguments              = query_arguments || config[:query_arguments]
      @full_url                     = join_url
      @document                     = parse(get_current)
      @timestamp                    = Time.at(document.xpath('//ts').text.to_i)
      @registers                    = []

      set_registers
    end

    def join_query_args
      accepted = %w{tot noteam v1 inst}
      arguments = []
      @query_arguments.each do |arg|
        arguments.push(arg) if accepted.include?(arg)
      end
      "?" + arguments.join('&')
    end

    # Concatentate and Return:
    # 1. base_url
    # 2. query_type(current or hist)
    # 3. string of query args
    # Return String

    def join_url
      @base_url + join_query_args
    end

    # Get the current values for all registers defined
    #
    # 1. loops through the registers
    # 2. converts the values to a Ruby Hash
    # 3. appends the each attriubute to a hash with name as key
    # 4. returns the hash

    def current
      results = {}
      registers.each {|r| results[r.name] = r}
      results
    end

    def get_stored
      RestClient.get(full_url) do |response, request, result, &block|
        case response.code
        when 200
          response
        else
          response.return!(request, result, &block)
        end
      end
    end

    def get_current
      RestClient.get(full_url) do |response, request, result, &block|
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
      @registers = []
      xml_register_collection = document.xpath('//r')
      xml_register_collection.each do |xml_reg|
        create_register_obj(xml_reg)
      end
    end

    def create_register_obj(xml_reg)
      new_reg_obj = EgaugeRuby::Register.new(register_to_hash(xml_reg))
      add_register(new_reg_obj)
    end

    def add_register(reg_obj)
      registers.push(reg_obj)
    end

    def register_to_hash(reg)
      hash = {}
      hash[:timestamp]      = timestamp
      hash[:name]           = reg.attributes["n"].value
      hash[:type]           = reg.attributes["t"].value
      hash[:value]          = reg.xpath("v").text.to_i
      hash[:instantaneous]  = reg.xpath("i").text.to_i
      hash
    end
  end
end
