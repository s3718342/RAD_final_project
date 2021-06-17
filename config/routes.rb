Rails.application.routes.draw do
  root 'questions#index'
  post 'submit' => 'questions#submit'
  get 'result' => 'questions#result', as: 'result'
end
