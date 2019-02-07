class Admin::ArtworksController < Admin::ApplicationController

  def new
    @article = Article.find_by(id: params[:article_id])
    @artwork = @article.artworks.new
  end

  def create
    @article = Article.find_by(id: params[:article_id])
    @artwork = @article.artworks.new(create_params)

    if @artwork.save
      redirect_to [:admin, @article]
    else
      render :new
    end
  end

  def edit
    @artwork = Artwork.find_by(hashed_id: params[:id])
    @article = @artwork.article
  end

  def update
    @artwork = Artwork.find_by(hashed_id: params[:id])
    @article = @artwork.article

    if @artwork.update(update_params)
      redirect_to [:admin, @article]
    else
      render :edit
    end
  end

  private

  def create_params
    params.require(:artwork).permit(:image, :caption)
  end

  def update_params
    params.require(:artwork).permit(:caption)
  end
end
