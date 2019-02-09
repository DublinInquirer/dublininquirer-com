class Comment < ApplicationRecord
  validates :nickname, presence: true, unless: :user_id?
  validates :email_address, presence: true, unless: :user_id?
  validates :content, presence: true

  belongs_to :user, optional: true
  belongs_to :article
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :children, class_name: "Comment", foreign_key: 'parent_id'

  before_create :preapprove_if_staff

  scope :not_spam, -> { where(marked_as_spam: false) }
  scope :approved, -> { where(status: 'approved') }
  scope :not_approved, -> { where(published_at: nil) }
  scope :created_since, -> (t) { where('created_at > ?', t) }

  def child?
    self.parent.nil?
  end

  def display_name
    return self.nickname if self.nickname.present?
    return self.user.comment_name if self.user.present? && self.user.nickname.present?

    'Anonymous commenter'
  end

  def content_formatted
    Formatter.remove_empty_paragraphs(self.content)
  end

  def content_markdown
    Upmark.convert(self.content_formatted)
  end

  def is_published?
    (self.status == 'approved') && self.published_at.present?
  end

  def is_spam?
    self.marked_as_spam
  end

  def toggle!
    if is_published?
      unapprove!
    else
      approve!
    end
  end

  def approve!
    self.status = 'approved'
    self.published_at = Time.now.utc
    self.save!
  end

  def unapprove!
    self.status = 'unapproved'
    self.published_at = nil
    self.save!
  end

  def mark_as_spam!
    self.marked_as_spam = true
    self.save!
    self.user.ban! if self.user.present?
  end

  private

  def preapprove_if_staff
    return true unless user.present?
    if user.is_staff?
      self.status = 'approved'
    end
    true
  end
end
