class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    if @message.save
      ActionCable.server.broadcast "chat_#{@chat.id}", message: @message.content, user: @message.user.name
      render json: @message, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:user_id, :content)
  end
end
