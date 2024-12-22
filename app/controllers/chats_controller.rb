class ChatsController < ApplicationController
  def create
    @chat = Chat.new(chat_params)
    if @chat.save
      render json: @chat, status: :created
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  def show
    @chat = Chat.find(params[:id])
    render json: @chat, include: :messages
  end

  private

  def chat_params
    params.require(:chat).permit(:advertisement_id, :user_id)
  end
end
