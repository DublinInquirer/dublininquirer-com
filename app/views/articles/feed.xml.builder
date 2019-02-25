#encoding: UTF-8

cache ['feed', @articles] do
  xml.instruct! :xml, :version => "1.0"
  xml.rss :version => "2.0" do
    xml.channel do
      xml.title "Dublin Inquirer"
      xml.author "info@dublininquirer.com"
      xml.description "Local, Independent, Different"
      xml.link "https://www.dublininquirer.com"
      xml.language "en"

      for article in @articles
        cache ['feed', article] do
          xml.item do
            if article.title
              xml.title article.title
            else
              xml.title ""
            end
            xml.author article.authors.map(&:full_name).to_sentence
            xml.pubDate article.issue_date.beginning_of_day.to_s(:rfc822)
            xml.link "https://www.dublininquirer.com" + article.path
            xml.guid article.id

            text = article.excerpt

            if article.featured_artwork.present?
              image_url = article.featured_artwork.image.medium.url
              image_caption = article.featured_artwork.caption || ''
              image_align = ""
              image_tag = "
                  <p><img src='" + image_url +  "' alt='" + image_caption + "' title='" + image_caption + "' align='center' /></p>
                "
              text = image_tag + Kramdown::Document.new(text).to_html
            end

            xml.description text

          end
        end
      end
    end
  end
end
