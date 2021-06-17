require 'open-uri'
require 'net/http'
require 'json'

class QuestionsController < ApplicationController
  
  before_action :checkValidity, only: [:submit, :result]
  before_action :getAnswersFromParams, only: [:submit]
  before_action :getQuestionsFromParams, only: [:submit, :result, :index]
  def index
    
    if not params[:questions]
    
      num_questions = 4
      if params[:num_questions]
        num_questions = params[:num_questions].to_i
      end
      
      if num_questions < 4 or num_questions > 8
        num_questions = 8
      end
      
      difficulty = 'easy'
      if params[:difficulty]
        difficulty = params[:difficulty]
      end
    
      categories = params[:categories]  
      
      distribution = {}
      # Get the distribution of questions 
      categories.each_with_index do |category|
        distribution[category] = rand()
      end
      
      total = distribution.values.inject(0, :+)
      
      remaining = num_questions
      ids = []
      distribution.each_with_index do |(category, prop), index|
        if index == distribution.size() - 1
          num = remaining
        else
          num = (prop/total * num_questions.to_f).round
        end
        
        remaining -= num
        
        if num > 0
          # Gets questions from the api using env variable api key
          URI.open("http://quizapi.io/api/v1/questions?apiKey=#{ENV['QUIZ_API_KEY']}&limit=#{num}&category=#{category}&difficulty=#{difficulty}") do |json|
            data = JSON.parse(json.read)
            # If there was no response, get random questions from db
            if not data or data.empty?
              ids << Question.where(category: category, difficulty: difficulty).order(Arel.sql("RANDOM()")).limit(num).ids
            else
              
              # Iterate over the questions
              data.each do |question|
                id = question["id"].to_i
                # Create a new question record if it does not exist in the db
                if not Question.exists?(id: id)
                  q = Question.create!(
                    id: question["id"], 
                    question: question["question"], 
                    explanation: question["explanation"], 
                    category: question["category"], 
                    difficulty: question["difficulty"]
                  )
                  question["answers"].each do |key, value|
                    if(value)
                      q.answers.create!(description: value, correct: helpers.true?(question["correct_answers"]["#{key}_correct"]))
                    end
                  end
                end
                ids << id
              end
            end
          end
        end
      end
      cookies[:num_questions] = num_questions
      cookies[:categories] = categories.to_json
      cookies[:difficulty] = difficulty

      @questions = Question.where(id: ids)
    end
    
  end
  
  def submit
    q_ids = @questions.ids
    a_ids = @answers.keys
    if a_ids.size == q_ids.size and q_ids & a_ids == q_ids
      score = q_ids.size
      
      @answers.each do |question, answers|
        
        actual = @questions.find(question).answers.where(correct: true).ids
        # symmetric difference between actual and submitted answers
        if not (actual - answers | answers - actual).empty?
          score -= 1
        end
        
      end
      
      # Create a history record
      Record.create!(
        time: DateTime.current,
        topic: JSON.parse(cookies[:categories]).join(", "), 
        difficulty: cookies[:difficulty],
        questions: @questions.ids.join(", "),
        result: "#{score}/#{@questions.size}"
      )
      
      if cookies[:history].blank? or cookies[:history].size == 0
        cookies[:history] = JSON.generate([helpers.generateHistory(score, @questions.size)])
      else
        history = JSON.parse(cookies[:history])
        history.prepend(helpers.generateHistory(score, @questions.size))
        cookies[:history] = history.to_json
      end
      redirect_to action: "result", score: score, questions: params[:questions]
      
    else
      #TODO: make flash or something when not all answers are filled in
      puts "Not all answers are filled in"
    end
  end
  
  def result
    if cookies[:history].blank? or cookies[:history].size == 0
      @history = []
    else
    @history = JSON.parse(cookies[:history])
    end
    @score = params[:score]
  end
  
  def getAnswersFromParams
    @answers = Hash[params[:answers].keys.map(&:to_i).zip(params[:answers].values.map{|row| row.map{|i| i.to_i}})]
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
