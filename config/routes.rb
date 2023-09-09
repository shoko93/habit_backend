Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post "/posts/create", to: "posts#create"
  post "/posts", to: "posts#index"
  post "/posts/like", to: "posts#like"
  post "/posts/bookmark", to: "posts#bookmark"
  post "/posts/bookmarks", to: "posts#bookmarks"
  post "/posts/comment", to: "posts#comment"
  get "/posts/:id/comments", to: "posts#comments"
  post "/posts/:id", to: "posts#get"
  # Defines the root path route ("/")
  # root "articles#index"
end
