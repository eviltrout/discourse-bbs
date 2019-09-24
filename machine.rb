# frozen_string_literal: true

class Machine
  POSTS_PER_PAGE = 4
  TOPICS_PER_PAGE = 10

  def initialize(api)
    @api = api
    transition_to(:main_menu)
  end

  def transition_to(state, data = nil)
    @state = state
    @data = data
  end

  def run
    loop do
      draw
      input(gets.chomp)
    end
  end

  def draw
    draw_method = "draw_#{@state}"
    send(draw_method) if respond_to?(draw_method)

    puts
    print "  Choose a Command: "
  end

  def input(cmd)
    input_method = "input_#{@state}"
    send(input_method, cmd.downcase) if respond_to?(input_method)
  end

  def draw_latest
    @topics = @api.latest_topics

    title("Latest Topics")
    divider
    @topics[0..TOPICS_PER_PAGE].each_with_index do |r, i|
      puts "#{col(37)}#{i.to_s.rjust(3)} #{col(35)}> #{col(0)}#{r['title']}"
      divider
    end
    puts

    menu_item('Main Menu')
  end

  def draw_topic
    @topic = @api.topic(@data.to_i)

    title(@topic['title'])

    post_stream = @topic['post_stream']
    posts = post_stream['posts']

    divider
    post_stream['stream'][0..POSTS_PER_PAGE].each do |s|
      if post = posts.find { |p| p['id'] == s }
        puts "#{col(37)}@#{post['username']} #{col(0)}<#{post['name']}>, #{post['created_at']}"
        puts

        text = Loofah.fragment(post['cooked']).scrub!(:strip).text
        puts WordWrap.ww(text, 80)
        divider
      end
    end
    puts

    menu_item("Latest Topics")
    menu_item("Main Menu")
  end

  def draw_main_menu
    render "main"

    ['Latest Topics', 'Goodbye - Logoff'].each { |i| menu_item(i) }
  end

  def input_main_menu(cmd)
    exit if cmd == "g"

    return transition_to(:latest) if cmd == "l"
  end

  def input_latest(cmd)
    return transition_to(:main_menu) if cmd == 'm'

    idx = cmd.to_i
    if @topics && idx.to_s == cmd && idx < @topics.size
      return transition_to(:topic, @topics[idx]['id'])
    end
  end

  def input_topic(cmd)
    return transition_to(:latest) if cmd == "l"
    return transition_to(:main_menu) if cmd == "m"
  end

protected

  def menu_item(item)
    code = item[0]
    puts "  #{col(37)}(#{col(33)}#{code}#{col(37)})#{col(36)}#{item[1..-1]}#{col(0)}"
  end

  def title(str)
    puts "\n#{col(33)}#{str}\n"
  end

  def divider
    puts "#{col(34)}" + ("-" * 80) + "#{col(0)}"
  end

  def render(file)
    puts File.read("ansi/#{file}")
  end

  def col(n)
    "\e[#{n}m"
  end

end
