class PortraitUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "portraits/#{ model.slug }"
  end

  def extension_whitelist
    %w(jpg jpeg gif png bmp tif tiff)
  end

  def filename
    return nil if original_filename.nil?
    "image.#{ model.portrait.try(:file).try(:extension) }"
  end
end
