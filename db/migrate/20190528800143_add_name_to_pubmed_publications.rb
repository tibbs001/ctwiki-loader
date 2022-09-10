class AddNameToPubmedPublications < ActiveRecord::Migration[7.0]
  def change
    add_column 'pubmed.publications', :name, :string
  end
end
