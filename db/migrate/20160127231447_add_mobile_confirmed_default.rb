class AddMobileConfirmedDefault < ActiveRecord::Migration
  def change
    change_column_default :mobiles, :confirmed, false
  end
end
