class ApiController < ApplicationController
  before_filter :find_mobile, only: %i(phone_attach phone_deattach)

  def phone_attach
    response = ApiLogicProcessor.phone_attach(@mobile, phone_params)
    render json: response
  end

  def phone_deattach
    response = ApiLogicProcessor.phone_deattach(@mobile, phone_params)
    render json: response
  end

  def convert_phone
    response = ApiLogicProcessor.convert_phone(convert_phone_params)
    render json: response
  end

  def convert_id
    response = ApiLogicProcessor.convert_id(convert_id_params)
    render json: response
  end

  private

  def find_mobile
    @mobile = Mobile.find_by(phone_number: phone_params[:phoneNumber])
  end

  def phone_params
    params.permit(:phoneNumber, :id, :code)
  end

  def convert_phone_params
    params.permit(phones: [])
  end

  def convert_id_params
    params.permit(ids: [])
  end
end
