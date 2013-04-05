module Nestful
  class Response
    attr_reader :response, :body, :headers, :parser

    def initialize(response, parser = nil)
      @response = response
      @body     = response.body
      @headers  = Headers.new(response.to_hash)
      @format   = Formats.for(headers.content_type)
      @parser ||= @format && @format.new
    end

    def as_json
      decoded
    end

    def to_json(*)
      as_json.to_json
    end

    def code
      response.code.to_i
    end

    def decoded
      @decoded ||= parser ? parser.decode(body) : body
    end

    def respond_to?(name)
      super || decoded.respond_to?(name) || response.respond_to?(name)
    end

    protected

    def method_missing(name, *args, &block)
      if decoded.respond_to?(name)
        decoded.send(name, *args, &block)
      elsif response.respond_to?(name)
        response.send(name, *args, &block)
      else
        super
      end
    end
  end
end

require 'nestful/response/headers'