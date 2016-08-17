require 'open-uri'
require 'nokogiri'
require 'robotex'
require 'active_record'



# DB定義
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "./db/companyinfo.db"
)

class Company < ActiveRecord::Base
end

class Urllist < ActiveRecord::Base
end


# Robotexインスタンス
@robourl = Urllist.find(1).url
robotex = Robotex.new
robotex.allowed?(@robourl)


# マイナビ
class Mynavi

  # Nokogiriメソッド
  def nokogiri(url)
    user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.63 Safari/537.36'
    charset = nil

    @doc = Nokogiri::HTML.parse(
      open(url, "User-Agent" => user_agent) do |f|
        charset = f.charset
        f.read
      end
    )
    return(@doc)
  end

  # 企業情報抽出メソッド
  def infoOut
    # @url = 'http://tenshoku.mynavi.jp/list/o11315/'
    # @url = 'http://tenshoku.mynavi.jp/list/o11105/'
    @url = Urllist.find(1).url
    uri = 'http://tenshoku.mynavi.jp'

    # サイト情報抽出
    @doc = self.nokogiri(@url)

    # 登録済みデータを削除。(DELETE・INSERT方式)
    # Company.delete_all

    # サイト情報分析
    @doc.xpath('//*[@id="content"]/form[@name="entry_form"]/div/div/div[@class="header"]').each do |contents|

      if @conNum != "" then
        @conNum = ""
      end

      if @eMailAdd != "" then
        @eMailAdd = ""
      end

      # 企業名情報
      @a_title = contents.css('p').first.inner_text
      puts "【企業名：#{@a_title}】"

      # href情報抽出
      a_href = contents.css('a').attr('href').value

      # URL連結
      @a_url = uri + a_href

      # タブチェック(メッセージタブ除外)
      @a_url = @a_url.sub("/msg/", "")

      # 企業詳細情報抽出
      @doc_p = self.nokogiri(@a_url)


      # 問い合わせ情報(住所)
      @doc_p.xpath('//*[@id="information"]/div[@class="block"]/div[@class="inquiry"]/table').each do |inqAdd|

        # 住所
        @address = inqAdd.css('p').inner_text
        @address = @address.sub("&nbsp【地図を見る】", "")
        if @address != "" then
          puts "■住所：#{@address}"
        else
          puts "■住所：－"
        end
      end


      # 問い合わせ情報(連絡先)
      @doc_p.xpath('//*[@id="information"]/div[@class="block"]/div[@class="inquiry"]/table/tbody/tr').each do |inqCont|

        # 初期値
        connumflag = 0

        # 要素条件分岐
        contact = inqCont.css('th').inner_text
        if contact == "電話番号" then
          @conNum = inqCont.css('td').inner_text
          if @conNum != "" then
            puts "■連絡先：#{@conNum}"
          else
            puts "■連絡先：－"
          end
          connumflag = 1
        end

        if connumflag == 1 then
          break
        end
      end

      @doc_p.xpath('//*[@id="information"]/div[@class="block"]/div[@class="inquiry"]/table/tbody/tr').each do |inqCont|

        # 初期値
        mailflag = 0
        count = 0

        # 要素条件分岐
        contact = inqCont.css('th').inner_text
        if contact == "E-mail" then

          # unicode記載のためUTF-8へエンコード
          mailAdd = inqCont.css('script').inner_text
          tmpAdd = mailAdd.gsub("(", ",").gsub(")", ",").split(/\s*,\s*/) # ,区切りセパレート
          index = tmpAdd.index {|item| item =~ /^\+/}                     # 配列index取得
          mail = tmpAdd.reject(&:empty?).map(&:to_i)                      # 空白(nil)削除＆エンコード用数値変換
          mail.each{|elm|
            if count < index then
              @eMailAdd << elm.chr("UTF-8")
              count += 1
            else
              break
            end
          }

          if @eMailAdd != "" then
            puts "■E-mail：#{@eMailAdd}"
          else
            puts "■E-mail：－"
          end
          mailflag = 1
        end

        if mailflag == 1 then
          break
        end

      end

      # 企業情報
      @doc_p.xpath('//*[@id="information"]/div[@class="block"]/div[@class="content"]/div[@class="table"]/table').each do |companyHp|

        # HPアドレス
        @homePage = companyHp.css('a').inner_text
        if @homePage != "" then
          puts "■企業HP：#{@homePage}\r\n"
          break
        end
      end

      # DB登録処理
      Company.create( :name => @a_title,
                      :address => @address,
                      :connum => @conNum,
                      :mail => @eMailAdd,
                      :site_url => @homePage,
                      :a_href => @a_url)

    end
  end

end
