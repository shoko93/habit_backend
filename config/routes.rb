Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post "/posts/create", to: "posts#create"
  post "/posts", to: "posts#index"
  post "/posts/like", to: "posts#like"
  post "/posts/bookmark", to: "posts#bookmark"
  post "/posts/bookmarks", to: "posts#bookmarks"
  post "/posts/comment", to: "posts#comment"
  get "/posts/:id/comments", to: "posts#comments"
  post "/posts/image", to: "posts#image"
  post "/posts/search", to: "posts#search"
  delete "/posts/:id/like", to: "posts#unlike"
  delete "/posts/:id/bookmark", to: "posts#unbookmark"
  post "/posts/:id", to: "posts#get"
  patch "/posts/:id", to: "posts#update"
  delete "/posts/:id", to: "posts#delete"
  get "/tags", to: "tags#index"
  # Defines the root path route ("/")
  # root "articles#index"
end
