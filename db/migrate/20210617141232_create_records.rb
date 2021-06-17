class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.datetime :time
      t.string :topic
      t.string :difficulty
      t.string :questions
      t.string :result
      t.timestamps
    end
  end
end
