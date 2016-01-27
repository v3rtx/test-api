class Mobile < ActiveRecord::Base
  validate :phone_number_and_uid_uniq

  scope :confirmed, -> { where(confirmed: true) }

  def phone_number_and_uid_uniq
    if Mobile.confirmed.where(phone_number: self.phone_number).
      where.not(id: self.id).any?
      errors.add(:phone_number, "has already been taken")
    elsif Mobile.confirmed.where(uid: self.uid).
      where.not(id: self.id).any?
      errors.add(:uid, "has already been taken")
    end
  end
end
