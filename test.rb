require 'active_record'

  # DB定義
  ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => "./companyinfo.db"
  )

class Company < ActiveRecord::Base
end


class Test

  def database
    test = "DB Up-Load..."
    Company.create(:site_url => test)
  end

end