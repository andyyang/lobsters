class Diffbot
  cattr_accessor :API_KEY

  # this needs to be overridden in config/initializers/production.rb
  @@API_KEY = nil

  API_URL = "http://www.diffbot.com/api/article"

  def self.get_url_text(url)
    if !@@API_KEY
      return
    end

    db_url = "#{API_URL}?token=#{@@API_KEY}&url=#{CGI.escape(url)}"

    begin
      s = Sponge.new
      s.timeout = 4
      res = s.fetch(db_url)
      if res.present?
        j = JSON.parse(res)

        # turn newlines into double newlines, so they become paragraphs
        return j["text"].gsub("\n", "\n\n")
      end
    rescue => e
      Rails.logger.error "error fetching #{db_url}: #{e.message}"
    end

    nil
  end
end
