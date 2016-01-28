require 'net/http'

class ApiLogicProcessor
  CODE_LENGTH = 4

  def self.phone_attach(mobile, phone_params)
    if mobile.present? && mobile.confirmed?
      {message: 'Already confirmed'}
    elsif phone_params[:code].blank?
      phone_attach_start(mobile, phone_params)
    else
      phone_attach_finish(mobile, phone_params)
    end
  end

  def self.phone_deattach(mobile, phone_params)
    if mobile.blank?
      {message: 'Already deatached'}
    elsif phone_params[:code].blank?
      phone_deattach_start(mobile, phone_params)
    else
      phone_deattach_finish(mobile, phone_params)
    end
  end

  def self.convert_phone(convert_phone_params)
    res = Mobile.confirmed.where(phone_number: convert_phone_params[:phones]).map do |mob|
      {phone: mob.phone_number, id: mob.uid}
    end
    {contacts: res}
  end

  def self.convert_id(convert_id_params)
    res = Mobile.confirmed.where(uid: convert_id_params[:ids]).map do |mob|
      {phone: mob.phone_number, id: mob.uid}
    end
    {contacts: res}
  end

  protected

  def self.generate_code
    chars = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...CODE_LENGTH).map { chars[rand(chars.length)] }.join
  end

  def self.send_confirmation(mobile)
    code = generate_code

    api_key = YAML::load_file(Rails.root.join('config', 'secrets.yml'))[Rails.env]['sms_api_key']

    api_url = "http://sms.ru/sms/send?api_id=#{api_key}" +
              "&to=#{mobile.phone_number}&text=Confirmation+code:+#{code}"
    uri = URI(api_url)
    response = Net::HTTP.get(uri)
    code
  end

  def self.phone_attach_start(mobile, phone_params)
    if mobile.blank? || mobile.uid != phone_params[:id]
      mobile = Mobile.new(uid: phone_params[:id], phone_number: phone_params[:phoneNumber])
      return {errors: mobile.errors.to_a.join("\n")} unless mobile.save
    end

    mobile.confirmation_code = send_confirmation(mobile)
    mobile.save!
    {message: 'Confirmation send'}
  end

  def self.phone_attach_finish(mobile, phone_params)
    mobile = Mobile.find_by(phone_number: phone_params[:phoneNumber], confirmation_code: phone_params[:code])
    if mobile
      unless mobile.update(confirmed: true, confirmation_code: generate_code)
        return {errors: mobile.errors.to_a.join("\n")}
      end
      Mobile.where(phone_number: mobile.phone_number).where(confirmed: false).destroy_all
      Mobile.where(uid: mobile.uid).where(confirmed: false).destroy_all
      {message: 'Phone confirmed'}
    else
      {message: 'Confirmation code is incorrect'}
    end
  end

  def self.phone_deattach_start(mobile, phone_params)
    mobile = Mobile.confirmed.find_by(phone_number: phone_params[:phoneNumber])
    mobile.confirmation_code = send_confirmation(mobile)
    mobile.save!
    {message: 'Confirmation send'}
  end

  def self.phone_deattach_finish(mobile, phone_params)
    if mobile.confirmation_code == phone_params[:code]
      mobile.destroy!
      {message: 'Phone confirmed'}
    else
      {message: 'Confirmation code is incorrect'}
    end
  end
end
