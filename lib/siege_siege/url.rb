module SiegeSiege
  class URL
    attr_reader :url, :http_method, :parameter

    def initialize(url, http_method = nil, parameter = nil)

      splat = url.split(' ')

      if splat.size > 1
        @url = splat[0]
        @http_method = splat[1].downcase.to_sym
        @parameter = splat[2]
      else
        @url = url
      end

      @http_method ||= http_method || :get
      @parameter ||= parameter || {}
    end

    def parameter_string
      case parameter
        when Hash
          parameter.to_param
        else
          parameter
      end
    end

    def to_siege_url
      if http_method && http_method.to_s.downcase == 'post'
        [url, 'POST', parameter_string]
      else
        url
      end
    end

    class RequireURL < StandardError

    end
  end
end
