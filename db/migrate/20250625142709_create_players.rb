class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.decimal :balance, precision: 10, scale: 2, default: 10000.0, null: false

      t.timestamps
    end
  end
end
