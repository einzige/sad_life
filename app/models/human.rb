class Human < ActiveRecord::Base
  self.table_name = 'humans'

  def finish_school!
    self.finished_school = true
    save!
  end
end
