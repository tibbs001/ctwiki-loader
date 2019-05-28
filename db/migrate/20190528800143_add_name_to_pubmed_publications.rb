class AddNameToPubmedPublications < ActiveRecord::Migration
  def change
    add_column 'pubmed.publications', :journal_qcode, :string
  end
end
