module ArticlesHelper
  def render_content(article)
    html = article.content
    ng_content = Nokogiri::HTML.fragment(html)

    # artwork
    ng_content.css('artwork').each do |artwork_el|
      hashed_id = artwork_el['id'].to_s
      a = Artwork.find_by(hashed_id: hashed_id)
      if a.present?
        artwork_el.replace a.rendered_element
      end
    end

    # tags

    if article.tags.autolinkable.any?
      article.tags.autolinkable.each do |autolink_tag|
        ng_content.css('p').each do |p_el|
          p_el.replace(p_el.to_html.gsub /#{autolink_tag.name}/i, '<a class="autolink" href="/tags/' + autolink_tag.slug + '">\&</a>')
        end
      end
    end

    # podcasts
    ng_content.css('podcast').each do |podcast_el|
      podcast_url = podcast_el['src'].to_s

      el = render partial: "articles/podcast", locals: { podcast_url: podcast_url }

      podcast_el.replace el
    end

    # wrapper
    ng_content.css('p, ul, ol, blockquote, iframe, h3, h4, h5, podcast, video, hr, script').each do |wrapped_el|
      wrapped_el.replace "<section class='content -#{ wrapped_el.name.downcase }'>#{ wrapped_el }</section>"
    end

    ng_content.to_html
  end
end