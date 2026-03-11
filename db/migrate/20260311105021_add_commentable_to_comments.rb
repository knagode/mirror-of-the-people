class AddCommentableToComments < ActiveRecord::Migration[8.0]
  def up
    add_column :comments, :commentable_type, :string
    add_column :comments, :commentable_id, :bigint

    execute "UPDATE comments SET commentable_type = 'Wish', commentable_id = wish_id WHERE wish_id IS NOT NULL"

    change_column_null :comments, :commentable_type, false
    change_column_null :comments, :commentable_id, false
    add_index :comments, [:commentable_type, :commentable_id]

    change_column_null :comments, :wish_id, true
  end

  def down
    remove_index :comments, [:commentable_type, :commentable_id]
    remove_column :comments, :commentable_type
    remove_column :comments, :commentable_id
    change_column_null :comments, :wish_id, false
  end
end
