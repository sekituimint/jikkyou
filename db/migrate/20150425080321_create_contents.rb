class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t| #=> この引数名「:channels」がテーブル名になる
      t.integer :channelid
      t.integer :tweetstime
      t.string :tweets
      t.integer :value
      t.timestamps  #=> この一行でcreated_atとupdated_atのカラムが定義される
    end
  end
end
