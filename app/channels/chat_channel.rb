class ChatChannel < ApplicationCable::Channel

  @@user_channels = {}


  def subscribed
    # chat = Chat.find(params[:chat_id])
    # stream_for chat
    user_id = params[:user_id]
    # Подписываемся на канал
    stream_from "user_#{user_id}"
    # Сохраняем ассоциацию user_id и текущего канала
    @@user_channels[user_id] = self
  end

  def unsubscribed
    user_id = params[:user_id]
    @@user_channels.delete(user_id)
  end

  def receive(data)
    contain = JSON.parse(data['message'])
    chat = Chat.find_by(user_id: contain['userID'], advertisement_id: contain['advertisementID'])
    if (chat.nil?)
      chat = Chat.new(user_id: contain['userID'], advertisement_id: contain['advertisementID'])
    end
    chat.save

    msg = Message.new(content: contain['message'], chat: chat, user: User.find_by(contain['userID']), state: 'nonsend')
    if ()

    # Optionally, you can broadcast the message to all subscribers
    # ActionCable.server.broadcast("chat_channel", message: message)
  end
end
