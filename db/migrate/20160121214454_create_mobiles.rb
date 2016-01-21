class CreateMobiles < ActiveRecord::Migration
  def change
    create_table :mobiles do |t|
      t.string :uid
      t.string :phone_number
      t.string :confirmation_code
      t.boolean :confirmed

      t.timestamps null: false
    end
  end
end
