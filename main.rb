# encoding: utf-8
require 'rubygems'
require 'sms_ru'
require 'clockwork'
require 'mechanize'
include Clockwork

phone  = '71234567890' # заменить на свой номер телефона
api_id = 'abcdefgh-1234-5678-6534-sad6sa85das' # заменить на api_id

def get_results
  agent = Mechanize.new
  results = []
  agent.get('http://www.liveresult.ru/?cat=171108') do |page| # запрос на сайт
    page.links.each do |link| # ищем все ссылки
      break if link.text == 'Сброс' # пока не дойдём до ссылки "Сброс"
      results << link.text if link.text.match /\d+:\d+/ # Запоминаем текст ссылки, если в ней присутствует счёт
    end
  end
  results
end

handler do |job|
  results = get_results
  sms = SmsRu::SMS.new(api_id: api_id)
  results.each { |message| sms.send(to: phone, text: message)}
end

every(1.day, 'send_sms', :at => '06:00') # Запускаем в 6:00 по серверному времени