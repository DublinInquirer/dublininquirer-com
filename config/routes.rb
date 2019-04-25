require 'sidekiq/web'

Rails.application.routes.draw do
  # public stuff
  root to: 'home#show'

  resources :issues, only: [:index, :show]
  resources :categories, only: [:show]
  resources :tags, only: [:show]
  resources :authors, only: [:show, :index], path: 'contributors'
  resources :authors, only: [:show, :index], path: 'author'
  resources :comments, only: [:create]

  get '/search' => 'articles#search', as: 'search'

  get '/:year/:month/:day/:slug(/)' => 'articles#show', constraints: {
    year:       /\d{4}/,
    month:      /\d{1,2}/,
    day:        /\d{1,2}/
  }

  get 'feed', to: 'articles#feed', as: 'feed', format: 'xml'

  resources :comments, only: [:create]
  resources :contact_messages, only: [:create]
  get '/contact/:regarding' => 'contact_messages#new', as: 'contact_form'

  # projects

  namespace :projects do
    resources :election_surveys, only: [:show], path: 'elections' do
      resources :election_candidates, only: [:show], path: 'candidates' do
        collection do
          get '/areas/:id' => 'election_candidates#areas', as: 'area'
          get '/parties/:id' => 'election_candidates#parties', as: 'party'
        end
      end
    end
  end

  # misc pages

  get 'about', to: redirect('/imprint')
  get 'about-us', to: redirect('/imprint')
  get 'contact-us', to: redirect('/contact')
  get 'pick-up-print', to: redirect('/stockists')
  get 'stockists' => 'home#stockists', as: :stockists
  get 'imprint' => 'home#imprint', as: :imprint
  get 'contact' => 'home#contact', as: :contact
  get 'newsletter' => 'home#newsletter', as: :newsletter

  # user stuff

  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :user_sessions, only: [:create]
  resource :user_session, only: [:destroy]
  resources :users, only: [:create]
  get 'register' => 'users#new', as: :register
  get 'login' => 'user_sessions#new', as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
  put 'accept' => 'user_sessions#accept_cookies', as: :accept_cookies

  # user migration

  get 'migrate' => 'migration#new', as: :new_migration
  post 'migrate' => 'migration#create', as: :migration

  get 'migrate/hold' => 'migration#hold', as: :migrate_hold

  get 'migrate/payment' => 'migration#payment', as: :migrate_payment
  put 'migrate/payment' => 'migration#payment', as: :migrate_payment_save

  get 'migrate/plan' => 'migration#plan', as: :migrate_plan
  put 'migrate/plan/:plan' => 'migration#plan_save', as: :migrate_plan_save

  get 'migrate/welcome' => 'migration#welcome', as: :migrate_welcome

  get 'migrate/:token' => 'migration#show', as: :migrate
  put 'migrate/:token' => 'migration#set_password', as: :migrate_set_password

  # subscriptions

  resources :landing_pages, only: [:show], path: 'c'
  resources :products, path: 'subscribe', only: [:index, :show]
  resources :gift_subscriptions, path: 'gifts', only: [:index, :show, :create] do
    collection do
      get :thanks
    end
  end

  resources :subscriptions, only: [:new, :create] do
    collection do
      get :upgrade
      put :upgrade
      get :thanks
    end
  end

  resource :user, only: [:show, :edit, :update] do
    member do
      get :subscription
      put :subscription

      get :address
      put :address

      get :payment
      put :payment
    end
  end

  resources :invoices, only: [:show]

  # errors

  get "/404" => "errors#not_found"
  get "/500" => "errors#internal_server_error"

  # legacy

  get '/online-battlelines', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/online-battlelines/twitter.html')
  get '/crossing-the-divide', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/crossing-the-divide/crossingthedivide.html')
  get '/luas-collisions', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/luas-collisions/index.html')
  get '/bottle_banks', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/bottle_banks/index.html')
  get '/budget', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/budget/index.html')
  get '/christmas', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/christmas/index.html')
  get '/dcc_budget_2018', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/dcc_budget_2018/index.html')
  get '/derelict_sites', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/derelict_sites/index.html')
  get '/noac', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/noac/index.html')
  get '/playgrounds', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/playgrounds/index.html')
  get '/street_lighting', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/street_lighting/index.html')
  get '/vacant_dwellings', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/vacant_dwellings/index.html')
  get '/vacant_dwellings_highres', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/vacant_dwellings_highres/index.html')
  get '/cycle-commuting', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/cycle-commuting/index.html')
  get '/maps/sdz', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/maps/sdz.html')
  get '/bicycle-collisions/form/index.html', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/bicycle-collisions/form/index.html')
  get '/bicycle-collisions/visualisation/index.html', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/bicycle-collisions/visualisation/index.html')
  get '/vacant_sites', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/vacant_sites/index.html')
  get '/data_content/derelict_sites/DubInq.png', to: redirect('https://d1trxack2ykyus.cloudfront.net/projects/derelict_sites/assets/logo.png')
  get '/data_content/*path', to: redirect{ |params,request| "https://www.dublininquirer.com/#{ request.fullpath.gsub('/data_content/','') }" }
  get 'wp-content/*path', to: redirect{ |params,request| "https://d1trxack2ykyus.cloudfront.net#{ request.fullpath.gsub('wp-content/','') }" }

  # admin stuff

  put '/stop_impersonating', to: 'home#stop_impersonating'

  namespace :admin do
    root to: 'dashboard#show'
    get 'auto', to: 'dashboard#auto'
    resources :articles do
      member do
        get :edit_content
        put :update_content
      end
      resources :artworks, only: [:new, :create]
    end
    resources :issues, only: [:index, :show, :create] do
      member do
        put :publish
        put :unpublish
        put :reorder
      end
    end
    resources :tags do
      collection do
        get :autocomplete
      end
      member do
        get :merge
        post :merge
        put :display
        put :hide
      end
    end
    resources :artworks, only: [:edit, :update, :destroy]
    resources :authors
    resources :gift_subscriptions
    resources :users do
      resources :subscriptions, only: [:new, :create]
      member do
        put :reset_password
        put :impersonate
      end
    end
    resources :subscriptions, except: [:new, :create] do
      collection do
        put :import
      end
      member do
        put :change_product
        get :change_price
        put :change_price
        get :change_day
        put :change_day
        put :cancel
      end
    end
    resources :contact_messages
    resources :comments do
      member do
        put :toggle
        put :mark_as_spam
      end
    end
    resources :landing_pages
    resources :election_surveys, path: 'elections' do
      member { post :import }
      resources :election_candidates, path: 'candidates', only: [:show]
      resources :election_survey_questions, path: 'questions', only: [:show]
      resources :election_survey_responses, path: 'responses', only: [:show]
    end
  end

  mount Sidekiq::Web => '/sidekiq'

  # landing pages catch-all

  get '/:id', to: 'landing_pages#show', constraints: { id: /[a-z0-9-]+/ }
end
