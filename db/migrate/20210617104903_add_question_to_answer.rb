class AddQuestionToAnswer < ActiveRecord::Migration[5.2]
  def change
    add_reference :answers, :question, foreign_key: true, index: true
  end
end
