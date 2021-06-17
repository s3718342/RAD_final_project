class PagesController < ApplicationController
  def home
    @chooseable_categories = ["Linux", "DevOps", "SQL", "Code"]
    
    @categories = []
    if not (cookies[:categories].blank? or cookies[:categories].size == 0)
      
      
      @categories = JSON.parse(cookies[:categories])
    end
    if not (cookies[:num_questions].blank?)
      @num_questions = cookies[:num_questions].to_i
      if not (@num_questions > 0 and  @num_questions < 9)
        @num_questions = 6
      end
    end
  end
end
