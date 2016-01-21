class Mobile < ActiveRecord::Base
  validates :phone_number, uniqueness: true
end
