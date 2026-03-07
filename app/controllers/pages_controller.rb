class PagesController < ApplicationController
  def about
  end

  def prompt
    render plain: AiSummarizer.new.prompt, content_type: "text/plain"
  end
end
