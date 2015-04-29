class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t| #=> この引数名「:channels」がテーブル名になる
      t.string :title
      t.integer :elapsetime
      t.string :starttime
      t.integer :rows
      t.string :defaultname
      t.timestamps  #=> この一行でcreated_atとupdated_atのカラムが定義される
    end
  end
end
