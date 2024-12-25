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

  def send_message(data)
    # contain = JSON.parse(data)
    puts data['chat_id']
    chat = Chat.find_by(id: data['chat_id'])

    usr = User.find_by(id: data['my_id'])
    usr2 = Advertisement.find_by(id: data['adv_id']).user
    msg = Message.new(content: data['content'], chat: chat, user: usr, state: 'nonsend')
    puts data['content']
    msg.save

    if (usr.id == usr2.id)
      usr2 = chat.user
    end
    
    ActionCable.server.broadcast("user_#{usr2.id}", { title: "message", body: msg.as_json })

    # Optionally, you can broadcast the message to all subscribers
    # ActionCable.server.broadcast("chat_channel", message: message)
  end

  def get_chat_id(data)
    chat = Chat.find_by(user_id: data['my_id'], advertisement_id: data['adv_id'])
    if chat.nil?
      chat = Chat.new(user_id: data['my_id'], advertisement_id: data['adv_id'])
      chat.save
    end
    ActionCable.server.broadcast("user_#{data['my_id']}", { title: "current_chat", body: chat.as_json })
  end

  def get_my_founds_chats(data)
    # puts data['userID']
    user_id = data['userID']
    chats = Chat.joins(:advertisement)
            .where("chats.user_id = ?", user_id)
    ActionCable.server.broadcast("user_#{user_id}", { title: "chats", body: chats.as_json })
  end

  def get_my_advs_chats(data)
    # puts data['userID']
    user_id = data['userID']
    chats = Chat.joins(:advertisement)
            .where("advertisements.user_id = ?", user_id)
    ActionCable.server.broadcast("user_#{user_id}", { title: "chats", body: chats.as_json })
  end

  def get_messages(data)
    # user = User.find_by(id: data['userID'])
    # puts user.as_json
    # adv = Advertisement.find_by(id: data['advertisementID'])
    # puts adv.as_json
    chat = Chat.find_by(id: data['chat_id'])
    if chat.nil?
      puts 'BEDA'
    else
      messages = chat.messages
      ActionCable.server.broadcast("user_#{data['my_id']}", {title: "list_of_messages", body: messages.as_json})
    end
  end
end
