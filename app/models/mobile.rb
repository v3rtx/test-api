class Mobile < ActiveRecord::Base
  validates :phone_number, uniqueness: true
  validates :uid, uniqueness: true
end
