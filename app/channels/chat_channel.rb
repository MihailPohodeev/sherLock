class ChatChannel < ApplicationCable::Channel

  @@user_channels = {}


  def subscribed
    # chat = Chat.find(params[:chat_id])
    # stream_for chat
    Rails.logger.info "User #{params[:user_id]} subscribed to ChatChannel"
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
    chat = Chat.find_by(user_id: contain['myID'], advertisement_id: contain['advertisementID'])
    if (chat.nil?)
      chat = Chat.new(user_id: contain['myID'], advertisement_id: contain['advertisementID'])
      chat.save
    end

    puts contain['myID']
    puts contain['toID']
    usr = User.find_by(id: contain['myID'])
    msg = Message.new(content: contain['message'], chat: chat, user: usr, state: 'nonsend')
    # puts msg.as_json()
    msg.save

    puts "user_#{contain['toID']}"
    ActionCable.server.broadcast("user_#{contain['toID']}", { title: "message", body: usr.chats.as_json })

    # Optionally, you can broadcast the message to all subscribers
    # ActionCable.server.broadcast("chat_channel", message: message)
  end

  def get_my_chats(data)
    # puts data['userID']
    user_id = data['userID']
    chats = Chat.joins(:advertisement)
            .where("chats.user_id = ? OR advertisements.user_id = ?", user_id, user_id)
    ActionCable.server.broadcast("user_#{user_id}", { title: "chats", body: chats.as_json })
  end

  def get_messages(data)
    chat = Chat.find_by(user_id: data['UserID'], advertisement_id: data['advertisementID'])
    if chat.nil?
      puts 'BEDA'
    else
      puts chat.as_json
    end
  end
end
