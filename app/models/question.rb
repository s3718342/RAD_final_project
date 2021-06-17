class Question < ApplicationRecord
  has_many :answers, dependent: :delete_all
end
