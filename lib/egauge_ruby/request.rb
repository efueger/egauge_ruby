require 'rubygems'
require 'rest-client'
require 'json'
require 'awesome_print'
require 'pry'
require 'nokogiri'

module EgaugeRuby
  class Register
    attr_accessor :timestamp, :interval, :name, :type, :value, :instantaneous

    def initialize(config = {})
      @timestamp      = config[:timestamp]
      @interval       = config[:interval]
      @name           = config[:name]
      @type           = config[:type]
      @value          = config[:value]
      @instantaneous  = config[:instantaneous]
    end

    def to_hash
      hash = {}
      hash[:timestamp]        = timestamp
      hash[:interval]         = interval
      hash[:name]             = name
      hash[:type]             = type
      hash[:value]            = value
      hash[:instantaneous]    = instantaneous
      hash
    end

    def calc_instantaneous(another_register)
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

    attr_accessor :base_url, :request_type, :query_arguments, :full_url,
                  :registers, :document, :timestamp, :interval

    def initialize(base_url:, request_type: "current", query_arguments: [], config: {})
      @base_url                     = base_url || config[:base_url]
      @request_type                 = request_type || config[:request_type]
      @query_arguments              = query_arguments || config[:query_arguments]
      @full_url                     = join_url
      @document                     = parse(get_current)
      @timestamp                    = set_timestamp
      @interval                     = set_interval
      @registers                    = []

      set_registers
    end

    def set_timestamp
      case request_type
      when "current"
        Time.at(document.xpath('//ts').text.to_i)
      when "stored"
        timestamp = document.xpath("//data").xpath("@time_stamp").text
        Time.at(timestamp.hex)
      else
      end
    end

    def set_interval
      case request_type
      when "current"
        1
      when "stored"
        interval = document.xpath("//data").xpath("@time_delta").text.to_i
      else
      end
    end

    def join_query_args
      # accepted = %w{tot noteam v1 inst}
      arguments = []
      @query_arguments.each do |arg|
        arguments.push(arg)
      end
      "?" + arguments.join('&')
    end

    # Concatentate and Return:
    # 1. base_url
    # 2. query_type(current or hist)
    # 3. string of query args
    # Return String

    def join_url
      @base_url +  api_url + join_query_args
    end

    def api_url
      case request_type
      when "current"
        "/cgi-bin/egauge"
      when "stored"
        "/cgi-bin/egauge-show"
      else
        ArgumentError "Request type not recognized\nPlease use either 'current' or 'stored'."
      end
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
      case request_type
      when "current"
        xml_register_collection = document.xpath('//r')
        xml_register_collection.each do |xml_reg|
          create_register_obj(current_register_to_hash(xml_reg))
        end
      when "stored"
        xml_register_values = document.xpath('//r')
        xml_column_collection = document.xpath('//cname')

        xml_register_values.each_with_index do |value_collection, row_index|
          row_timestamp = timestamp - (row_index * interval)
          values = value_collection.xpath('c')

          values.each_with_index do |value, index|
            register_column = xml_column_collection[index]
            new_reg = stored_register_to_hash(value, row_timestamp, register_column)
            create_register_obj(new_reg)
          end
        end
      else
      end
    end
    # Poor implementation
    # instantaneous =  (value.text.to_i - document.xpath('//r')[index - 1].xpath('c')[index].text.to_i) if index > 0
    # def get_instantaneous(row_set, index)
    #   if index > 0
    #     row_set[index - 1].xpath('c')[index].text
    #   else
    #     row_set[index].xpath('c')[index].text
    #   end
    # end

    def create_register_obj(reg)
      new_reg_obj = EgaugeRuby::Register.new(reg)
      add_register(new_reg_obj)
    end

    def add_register(reg_obj)
      registers.push(reg_obj)
    end

    def stored_register_to_hash(value, row_timestamp, register_column)
      hash              = {}
      hash[:timestamp]  = row_timestamp
      hash[:interval]   = interval
      hash[:name]       = register_column.text
      hash[:type]       = register_column.attributes["t"].value
      hash[:value]      = value.text.to_i
      hash[:interval]   = document.xpath('//data').xpath("@time_delta").text.to_i
      hash
    end

    def current_register_to_hash(reg)
      hash = {}
      hash[:timestamp]      = timestamp
      hash[:interval]       = interval
      hash[:name]           = reg.attributes["n"].value
      hash[:type]           = reg.attributes["t"].value
      hash[:value]          = reg.xpath("v").text.to_i
      hash[:instantaneous]  = reg.xpath("i").text.to_i
      hash
    end
  end
end
