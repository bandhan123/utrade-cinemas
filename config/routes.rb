Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      resources :cinemas do
        collection do
          get :get_cinemas
          get :get_movie_info
          get :get_movie_shows
          get :get_food_beverage
          get :get_movie_coupons
          get :get_movie_avail
        end
      end
    end
  end
  # Defines the root path route ("/")
  # root "articles#index"
end
