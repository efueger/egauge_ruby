require 'rest-client'
require 'json'
require 'nokogiri'

module EgaugeRuby
  class Gauge
    attr_accessor :request, :url, :data

    def initialize(url)
      @url = url
      @request = EgaugeRuby::Request.new(base_url: url, query_arguments: ['total', 'inst'])
      @data = Data.new(request)
    end

    def current
      results = {}
      data.registers.each { |r| results[r.name] = r.instantaneous }
      results
    end

    def stored(start_time, end_time, interval)
      start_time = Time.parse(start_time)
      end_time = Time.parse(end_time)

      seperator_args = {
        seconds: 'S',
        minutes: 'm',
        hours: 'h',
        days: 'd',
      }

      request_config = {
        base_url: url,
        type: "stored",
        query_arguments: [seperator_args[interval], "f=#{start_time.to_i}", "t=#{end_time.to_i}"],
      }

      @request = Request.new(request_config)
      @data = Data.new(request)

      data.registers_to_hash
    end
  end

  class Data
    attr_accessor :registers, :document, :timestamp, :interval, :request

    def initialize(request)
      @document = Nokogiri.parse(request.response)
      @request = request
      @timestamp = set_timestamp
      @interval = set_interval
      @registers = []

      set_registers
    end

    def registers_to_hash
      registers.group_by{ |reg| reg.name }
    end

    def set_timestamp
      case request.type
      when "current"
        Time.at(document.xpath('//ts').text.to_i)
      when "stored"
        timestamp = document.xpath("//data").xpath("@time_stamp").text
        Time.at(timestamp.hex)
      else
      end
    end

    def set_interval
      case request.type
      when "current"
        1
      when "stored"
        interval = document.xpath("//data").xpath("@time_delta").text.to_i
      else
      end
    end

    def set_registers
      @registers = []
      case request.type
      when "current"
        xml_register_collection = document.xpath('//r')
        xml_register_collection.each do |xml_reg|
          create_register_obj(current_register_to_hash(xml_reg))
        end
      when "stored"
        xml_register_rows = document.xpath('//r')
        xml_column_names = document.xpath('//cname')

        xml_register_rows.each_with_index do |row, row_index|
          row_timestamp = timestamp - (row_index * interval)
          values = row.xpath('c')

          next if row_index == 0

          values.each_with_index do |value, index|
            register_column = xml_column_names[index]
            instantaneous = compare_values(row_index, index, value)
            new_reg = stored_register_to_hash(value, instantaneous, row_timestamp, register_column)
            create_register_obj(new_reg)
          end
        end
      else
      end
    end

    def compare_values(row_index, value_index, value)
      # Get the value at the same value index and row index -1

      xml_register_rows = document.xpath('//r')
      other_value = xml_register_rows[row_index-1].xpath('c')[value_index]

     (other_value.text.to_i - value.text.to_i) / interval
    end

    def create_register_obj(reg)
      new_reg_obj = EgaugeRuby::Register.new(reg)
      add_register(new_reg_obj)
    end

    def add_register(reg_obj)
      registers.push(reg_obj)
    end

    def stored_register_to_hash(value, instantaneous, row_timestamp, register_column)
      hash                  = {}
      hash[:timestamp]      = row_timestamp
      hash[:interval]       = interval
      hash[:name]           = register_column.text
      hash[:type]           = register_column.attributes["t"].value
      hash[:value]          = value.text.to_i
      hash[:instantaneous]  = instantaneous
      hash[:interval]       = document.xpath('//data').xpath("@time_delta").text.to_i
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
      hash[:timestamp]        = timestamp.to_s
      hash[:interval]         = interval
      hash[:name]             = name
      hash[:type]             = type
      hash[:value]            = value
      hash[:instantaneous]    = instantaneous
      hash
    end

    def calc_instantaneous(another_register)
    end

    def power
      { name => instantaneous }
    end

    def to_json
      result = []
      result.push(
        self.to_hash
        )
      JSON.pretty_generate(result)
    end
  end

  class Request

    attr_accessor :base_url, :type, :query_arguments, :full_url, :response

    def initialize(base_url:, type: "current", query_arguments: [], config: {})
      @base_url                     = base_url || config[:base_url]
      @type                         = type || config[:type]
      @query_arguments              = query_arguments || config[:query_arguments]
      @full_url                     = join_url
      @response                     = get_xml
    end

    def join_query_args
      arguments = []
      @query_arguments.each do |arg|
        arguments.push(arg)
      end
      "?" + arguments.join('&')
    end

    def join_url
      @base_url +  api_url + join_query_args
    end

    def api_url
      case type
      when "current"
        "/cgi-bin/egauge"
      when "stored"
        "/cgi-bin/egauge-show"
      else
        ArgumentError "Request type not recognized\nPlease use either 'current' or 'stored'."
      end
    end

    def get_xml
      RestClient.get(full_url, timeout: 30) do |response, request, result, &block|
        case response.code
        when 200
          response
        else
          response.return!(request, result, &block)
        end
      end
    end
  end
end
