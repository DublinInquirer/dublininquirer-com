namespace :artwork do
  task recreate_versions: :environment do
    (Artwork.count / 50).times do |i|
      Raven.capture_message 'Starting artwork page', extra: { page: (i + 1).to_s }
      Artwork.order('created_at asc').page(i + 1).per(50).each do |artwork|
        begin
          artwork.image.recreate_versions!
        rescue CarrierWave::ProcessingError
          Raven.capture_message 'Error recreating version.', extra: { artwork_id: artwork.id }
        end
      end
    end
  end
end
