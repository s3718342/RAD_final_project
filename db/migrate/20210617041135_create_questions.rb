class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions, {:id => false} do |t|
      t.integer :id, primary_key: true
      t.string :question
      t.string :explanation
      t.string :category
      t.string :difficulty
      t.timestamps
    end
  end
end
