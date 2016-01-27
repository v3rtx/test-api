require 'net/http'

class ApiController < ApplicationController
  CODE_LENGTH = 4

  def phone_attach
    mobile = Mobile.find_by(phone_number: phone_params[:phoneNumber])

    if mobile.present? && mobile.confirmed.present? && mobile.confirmed
      render json: {message: 'Already confirmed'}
    elsif phone_params[:code].present?

      if mobile.confirmation_code == phone_params[:code]
        mobile.update!(confirmed: true)
        render json: {message: 'Phone confirmed'}
      else
        render json: {message: 'Confirmation code is incorrect'}
      end
    else
      if !mobile.nil?
        mobile.destroy!
      end
      mobile = Mobile.new(uid: phone_params[:id], phone_number: phone_params[:phoneNumber])
      mobile.confirmation_code = send_confirmation(mobile)
      mobile.save!
      render json: {message: 'Confirmation send'}
    end
  end

  def phone_deattach
    mobile = Mobile.find_by(phone_number: phone_params[:phoneNumber])

    if mobile.blank?
      render json: {message: 'Already deatached'}
    elsif phone_params[:code].present?
      if mobile.confirmation_code == phone_params[:code]
        mobile.destroy!
        render json: {message: 'Phone confirmed'}
      else
        render json: {message: 'Confirmation code is incorrect'}
      end
    else
      mobile = Mobile.find_by(phone_number: phone_params[:phoneNumber])
      mobile.confirmation_code = send_confirmation(mobile)
      mobile.save!
      render json: {message: 'Confirmation send'}
    end
  end

  def convertPhone
    res = []
    Mobile.where(phone_number: contacts_params[:phones], confirmed: true).each do |mob|
      res << {phone: mob.phone_number, id: mob.uid}
    end
    render json: {contacts: res}
  end

  def convertId
    res = []
    Mobile.where(uid: contacts_params2[:ids], confirmed: true).each do |mob|
      res << {phone: mob.phone_number, id: mob.uid}
    end
    render json: {contacts: res}
  end
  private

  def send_confirmation(mobile)
    chars = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    code = (0...CODE_LENGTH).map { chars[rand(chars.length)] }.join

    api_key = YAML::load_file(Rails.root.join('config', 'secrets.yml'))[Rails.env]['sms_api_key']

    api_url = "http://sms.ru/sms/send?api_id=#{api_key}" +
              "&to=#{mobile.phone_number}&text=Confirmation+code:+#{code}"
    uri = URI(api_url)
    response = Net::HTTP.get(uri)
    code
  end

  def phone_params
    params.permit(:phoneNumber, :id, :code)
  end

  def contacts_params
    params.permit(phones: [])
  end

  def contacts_params2
    params.permit(ids: [])
  end
end
