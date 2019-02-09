require 'rails_rinku'

module CommentsHelper
  def render_comment(comment_body)
    auto_link(comment_body, html: { target: '_blank' }) do |text|
      truncate(text, length: 36)
    end
  end
end