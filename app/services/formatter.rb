class Formatter
  def self.remove_empty_paragraphs(text)
    doc = Nokogiri::HTML.fragment(text)
    doc.css('p').find_all.each do |p|
      p.remove if p.content.blank?
    end
    doc.to_html
  end
end
