class ArticleAuthor < ApplicationRecord
  belongs_to :article
  belongs_to :author

  validates :author, uniqueness: { scope: :article }
end
