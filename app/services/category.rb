class Category
  def self.all
    Article.all.pluck(:categories).flatten.uniq
  end

  def self.featured
    [
      'city-desk',
      'unreal-estate',
      'culture-desk',
      'on-the-media',
      'the-dish',
      'opinion'
    ]
  end
end
