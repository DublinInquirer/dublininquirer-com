class HomeController < ApplicationController
  layout 'front', only: [:show]

  def show
    @current_issue = Rails.cache.fetch("/home/issue_current", expires_in: 1.minutes) do
      Issue.current
    end

    @articles = Rails.cache.fetch("/home/articles", expires_in: 5.minutes) do
      @current_issue ? @current_issue.articles.standard.includes(:authors, :artworks).by_position : Article.none
    end

    @cartoon = Rails.cache.fetch("/home/cartoon", expires_in: 5.minutes) do
      @current_issue ? @current_issue.articles.published.in_category('cartoon').includes(:authors, :artworks).first : Article.none
    end

    @cover = Rails.cache.fetch("/home/cover", expires_in: 5.minutes) do
      Article.published.in_category('cover').includes(:authors, :artworks).by_date.first
    end

    @recent_podcasts = Rails.cache.fetch("/home/podcast", expires_in: 5.minutes) do
      Article.published.in_category('podcast').includes(:authors, :artworks).by_date.limit(3)
    end

    @recent_motions = Rails.cache.fetch("/home/motions", expires_in: 1.hour) do
      get_recent_motions
    end
  end

  def stop_impersonating
    user = current_user
    stop_impersonating_user
    redirect_to [:admin, user]
  end

  def contact
  end

  def imprint
    @staff = Rails.cache.fetch("/imprint/masthead", expires_in: 1.day) do
      {
        editor: Author.find_or_create_by!(full_name: 'Lois Kapila'),
        deputy: Author.find_or_create_by!(full_name: 'Sam Tranum'),
        reporters: [
          Author.find_or_create_by!(full_name: 'Sean Finnan'),
          Author.find_or_create_by!(full_name: 'Erin McGuire'),
          Author.find_or_create_by!(full_name: 'Aura McMenamin'),
          Author.find_or_create_by!(full_name: 'Laoise Neylon')
        ]
      }
    end

    @columnists = Rails.cache.fetch("/imprint/columnists", expires_in: 1.day) do
      Author.where(full_name: ['Donal Fallon', 'Ebun Joseph', 'Niamh Kirk', 'Joe McGrath', 'David O’Connor','Odran Reid'])
    end

    @contributors = Rails.cache.fetch("/imprint/contributors", expires_in: 1.day) do
      Author.where(full_name: ['Martin Cook', 'Dan Grennan', 'Gary Ibbotson', 'Shrinidhi Kalwad', 'Haseena Manek', 'Luke Maxwell', 'David Monaghan', 'Melatu Uche Okorie', 'Christine O\'Donnell', 'Daniel Seery'])
    end
  end

  private

  def get_recent_motions
    begin
      Oj.load(HTTP.get("https://www.counciltracker.ie/motions.json").body).first(3)
    rescue HTTP::ConnectionError, OpenSSL::SSL::SSLError, NoMethodError
      []
    end
  end
end
