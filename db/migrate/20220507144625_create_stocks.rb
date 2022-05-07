class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.belongs_to :bearer, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :stocks, :name, unique: true, where: 'deleted_at is null'
    add_index :stocks, :deleted_at
  end
end
