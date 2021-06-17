class QuestionsController < ApplicationController
  
  before_action :getAnswersFromParams, :getQuestionsFromParams, only: [:submit]
  
  def index
    @questions = Question.order("RANDOM()").limit(1)
  end
  
  def submit
    q_ids = @questions.ids
    a_ids = @answers.keys
    if a_ids.size == q_ids.size and q_ids & a_ids == q_ids
      score = q_ids.size
      
      #TODO: multiple correct answers support 
      @answers.each do |_, answers|
        answers.each do |answer|
          if not answer.correct
            score -= 1
            break
          end
        end
      end
      
      puts score
      
      redirect_to action: "result", score: score
      
    else
      #TODO: make flash or something when not all answers are filled in
      puts "Not all answers are filled in"
    end
  end
  
  def result
    @score = params[:score]
  end
  
  def getAnswersFromParams
    @answers = Hash[params[:answers].keys.map(&:to_i).zip(params[:answers].values.map{|row| row.map{|i| Answer.find(i.to_i)}})]
  end
  
  def getQuestionsFromParams
    ids = eval(params[:questions])[:value]
    @questions = Question.where(id: ids)
  end
  
  def validateAnswers
    
  end
  
  
end
