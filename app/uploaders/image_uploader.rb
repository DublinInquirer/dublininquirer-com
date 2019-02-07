class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "artwork/#{ model.hashed_id }"
  end

  def extension_whitelist
    %w(jpg jpeg gif png bmp tif tiff)
  end

  def filename
    return nil if original_filename.nil?
    "image.#{ model.image.try(:file).try(:extension) }"
  end

  version :massive do
    process resize_to_fit: [2880, 2880]
    process :store_dimensions
  end

  version :large do
    process resize_to_fit: [1600, 1600]
  end

  version :medium do
    process resize_to_fit: [960, 960]
  end

  version :small do
    process resize_to_fit: [480, 480]
  end

  private

  def store_dimensions
    if file && model
      model.width_px, model.height_px = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end
end
