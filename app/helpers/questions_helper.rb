module QuestionsHelper
  
  def questionOptions(question)
    options = []
    
    answers = question.answers
    
    answers.each do |answer| 
      options.push([answer.description, answer.id])
    end
    
    return options
  end
  
end
