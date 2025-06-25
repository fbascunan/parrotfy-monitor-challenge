class CreateRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :rounds do |t|
      t.string :result, null: false
      t.decimal :total_bets, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
