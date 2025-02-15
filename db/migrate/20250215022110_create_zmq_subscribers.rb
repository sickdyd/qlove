class CreateZmqSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :zmq_subscribers do |t|
      t.string :host, null: false
      # Use smallint for port
      t.numeric :port, limit: 2, null: false
      t.string :username, null: false
      t.string :password, null: false
      t.boolean :started, default: false
      t.timestamps
    end
  end
end
