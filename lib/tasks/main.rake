#encoding: utf-8
desc 'watir'
task :watir => :environment do
  require 'watir-webdriver'


  module Watir

    class << self
      def default_timeout
        @default_timeout ||= 120
      end
    end
  end


  @url = 'http://tabor.ru'

  Headless.ly do

    def main
      @browser.goto "#{@url}/"
      return raise 'главная страница не грузится' unless begin
        @browser.li(:class => 'user__item user_woman').when_present.exists?
      rescue
        false
      end
    end

    def login
      return raise 'не могу залогиниться' unless begin
        @browser.link(:id => 'buttonAuth').click
        @browser.text_field(:id => 'session_user_login').when_present.set 'teacplusplus'
        @browser.text_field(:id => 'session_user_password').when_present.set '11235813'
        @browser.input(:value => 'Войти').when_present.click
        @browser.input(:value => 'Войти').wait_while_present
        true
      rescue
        false
      end
    end

    def pay
      return raise 'не работает оплата' unless begin
        @browser.link(:class => 'score').click
        @browser.div(:text, 'Пополнение монет').when_present
        @browser.send_keys :escape
        @browser.div(:text, 'Пополнение монет').wait_while_present
        true
      rescue
        false
      end
    end

    def event
      return raise 'не работаеют события' unless begin
        @browser.link(:id => 'eventLed').click
        @browser.div(:text, 'События').when_present
        @browser.send_keys :escape
        @browser.div(:text, 'События').wait_while_present
        true
      rescue
        false
      end
    end

    def system
      return raise 'не работаеют системные' unless begin
        @browser.link(:id => 'notificationLed').click
        @browser.div(:text, 'Системные сообщения').when_present
        @browser.send_keys :escape
        @browser.div(:text, 'Системные сообщения').wait_while_present
        true
      rescue
        false
      end
    end

    def friend
      return raise 'не работают друзья' unless begin
        @browser.goto "#{@url}/friends"
        @browser.h1(:text, 'Мои друзья').when_present.exists?
      rescue
        false
      end
    end

    def message
      return raise 'не работают сообщения' unless begin
        @browser.link(:id => 'messageLed').click
        @browser.div(:text, 'Мои сообщения').when_present
        Watir::Wait.until { !@browser.span(:class => 'submit-status').visible? }
        @browser.send_keys :escape
        @browser.div(:text, 'Мои сообщения').wait_while_present
        true
      rescue
        false
      end
    end

    def guest
      return raise 'не работают гости' unless begin
        @browser.goto "#{@url}/guests"
        @browser.h1(:text, 'Гости').when_present.exists?
      rescue
        false
      end
    end

    def service
      return raise 'не работают сервисы' unless begin
        @browser.goto "#{@url}/services/list"
        @browser.h1(:text, 'Сервисы').when_present.exists?
      rescue
        false
      end
    end

    def shop
      return raise 'не работает магазин' unless begin
        @browser.goto "#{@url}/shop"
        @browser.h1(:text, 'Магазин').when_present.exists?
      rescue
        false
      end
    end

    def search
      return raise 'не работаеют поиск' unless begin
        @browser.link(:class => 'online__link online__woman').click
        @browser.li(:class => 'comment').when_present.exists?
      rescue
        false
      end
    end

    def schedule
      main
      login
      pay
      event
      system
      message
      friend
      guest
      service
      shop
      search
    end


    @browser = Watir::Browser.new
    begin

      begin
        schedule
      rescue
        @browser.close
        @browser = Watir::Browser.new
        schedule
      end

      Status.create!(:error => false, :code => 'все работает')
      print 'все работает'
    rescue  => e
      print e.message
      last_status = Status.order("created_at DESC").first
      new_status = Status.create!(:error => true, :code => e.message)
      is_new_error = ((last_status.present? && last_status.error && ((new_status.created_at - last_status.created_at) > 1.hours)) || (last_status.blank?) || (last_status.present? && !last_status.error))
      if is_new_error
        SmsGate.send("Ошибка: #{e.message}", '+79612966010', 3159)
        SmsGate.send("Ошибка: #{e.message}", '+375295607342', 3159)
      end
    ensure
      @browser.close
    end
  end


end