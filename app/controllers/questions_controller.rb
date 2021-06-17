class QuestionsController < ApplicationController
  
  before_action :checkValidity, only: [:submit, :result]
  before_action :getAnswersFromParams, only: [:submit]
  before_action :getQuestionsFromParams, only: [:submit, :result, :index]
  def index
    puts "print"
    puts params[:questions]
    
    if not @questions
      @questions = Question.order(Arel.sql("RANDOM()")).limit(2)
    end
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
      
      if cookies[:history].blank? or cookies[:history].size == 0
        cookies[:history] = JSON.generate([helpers.generateHistory(score, @questions.size)])
      else
        history = JSON.parse(cookies[:history])
        history << helpers.generateHistory(score, @questions.size)
        cookies[:history] = history.to_json
      end
      redirect_to action: "result", score: score, questions: params[:questions]
      
      print cookies[:history]
      
    else
      #TODO: make flash or something when not all answers are filled in
      puts "Not all answers are filled in"
    end
  end
  
  def result
    @history = JSON.parse(cookies[:history])
    @score = params[:score]
  end
  
  def getAnswersFromParams
    @answers = Hash[params[:answers].keys.map(&:to_i).zip(params[:answers].values.map{|row| row.map{|i| Answer.find(i.to_i)}})]
  end
  
  def getQuestionsFromParams
    if params[:questions]
      ids = eval(params[:questions])[:value]
      @questions = Question.where(id: ids)
    end
  end
  
  def checkValidity
    if not params[:questions] 
      redirect_to root_path
    end
  end
  
  
end
