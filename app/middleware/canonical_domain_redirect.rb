class CanonicalDomainRedirect
  CANONICAL_HOST = "www.zrcaloljudi.com"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host != CANONICAL_HOST && request.path != "/up"
      [301, { "Location" => "https://#{CANONICAL_HOST}#{request.fullpath}" }, []]
    else
      @app.call(env)
    end
  end
end
