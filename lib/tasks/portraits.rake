namespace :portraits do
  task :parameterize do
    path = "./app/assets/images/candidates"
    Dir.open(path).each do |p|
      next unless ['.jpg', '.jpeg'].include?(File.extname(p).downcase)
      old_name = File.basename(p, File.extname(p))
      new_name = (old_name.parameterize).gsub('_','-') + '.jpg'
      next if p == new_name
      FileUtils.mv("#{path}/#{p}", "#{path}/#{new_name}")
    end
  end
end