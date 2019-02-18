module ArticlesHelper
  def render_content(html)
    ng_content = Nokogiri::HTML.fragment(html)

    # artwork
    ng_content.css('artwork').each do |artwork_el|
      hashed_id = artwork_el['id'].to_s
      a = Artwork.find_by(hashed_id: hashed_id)
      if a.present?
        artwork_el.replace a.rendered_element
      end
    end

    # wrapper
    ng_content.css('p, ul, ol, blockquote, iframe, h3, h4, h5, podcast, hr, script').each do |wrapped_el|
      wrapped_el.replace "<section class='content'>#{ wrapped_el }</section>"
    end

    # podcasts
    ng_content.css('podcast').each do |podcast_el|
      podcast_url = podcast_el['src'].to_s

      el = render partial: "articles/podcast", locals: { podcast_url: podcast_url }

      podcast_el.replace el
    end

    ng_content.to_html
  end

  def get_artist_from_cover_article(article)
    article.title.scan(/Issue \d*: By (.+)$/i).first.try(:first)
  end
end