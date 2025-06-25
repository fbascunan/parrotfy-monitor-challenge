class CreateBets < ActiveRecord::Migration[8.0]
  def change
    create_table :bets do |t|
      t.references :player, null: false, foreign_key: true
      t.references :round, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :color, null: false

      t.timestamps
    end
    
    add_index :bets, [:player_id, :round_id], unique: true
  end
end
