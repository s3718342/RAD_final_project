Rails.application.routes.draw do
  root 'pages#home'
  post 'submit' => 'questions#submit'
  get 'quiz' => 'questions#index'
  get 'history' => 'pages#history'
  get 'result' => 'questions#result', as: 'result'
end
