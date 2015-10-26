class CreateRefererStats < ActiveRecord::Migration
  def change
    create_table :referer_stats do |t|
      t.string :referer_name
      t.integer :lifetime
      t.integer :annual
      t.integer :basic

      t.timestamps null: false
    end

    add_index :referer_stats, :referer_name
  end
end