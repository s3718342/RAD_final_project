class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.string :description
      t.boolean :correct
      t.belongs_to :question, index: true, foreign_key: true
      t.timestamps
    end
  end
end
